// Flips macOS's shared scroll direction when an external mouse connects or
// disconnects: reverse while a mouse is connected, natural otherwise.
//
//   scroll-switch          watch for mouse connect/disconnect (run by launchd)
//   scroll-switch status   print whether a mouse is connected and the direction

#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/hid/IOHIDKeys.h>
#include <dlfcn.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

typedef bool (*get_fn)(void);
typedef void (*set_fn)(bool);

static get_fn get_natural;
static set_fn set_natural;
static int last_mouse_present = -1;
static CFRunLoopTimerRef pending;

static void log_msg(const char *msg) {
    char ts[32];
    time_t now = time(NULL);
    strftime(ts, sizeof ts, "%Y-%m-%d %H:%M:%S", localtime(&now));
    fprintf(stderr, "%s %s\n", ts, msg);
}

static bool load_scroll_functions(void) {
    void *h = dlopen("/System/Library/PrivateFrameworks/PreferencePanesSupport.framework/PreferencePanesSupport", RTLD_LAZY);
    if (!h) return false;
    get_natural = (get_fn)dlsym(h, "swipeScrollDirection");
    set_natural = (set_fn)dlsym(h, "setSwipeScrollDirection");
    return get_natural && set_natural;
}

static bool has_usage(CFArrayRef pairs, int page, int usage) {
    for (CFIndex i = 0; i < CFArrayGetCount(pairs); i++) {
        CFDictionaryRef pair = CFArrayGetValueAtIndex(pairs, i);
        CFNumberRef p = CFDictionaryGetValue(pair, CFSTR(kIOHIDDeviceUsagePageKey));
        CFNumberRef u = CFDictionaryGetValue(pair, CFSTR(kIOHIDDeviceUsageKey));
        int pv = 0, uv = 0;
        if (p) CFNumberGetValue(p, kCFNumberIntType, &pv);
        if (u) CFNumberGetValue(u, kCFNumberIntType, &uv);
        if (pv == page && uv == usage) return true;
    }
    return false;
}

static bool is_external_mouse(io_service_t dev) {
    bool result = false;
    CFTypeRef builtin = IORegistryEntryCreateCFProperty(dev, CFSTR(kIOHIDBuiltInKey), kCFAllocatorDefault, 0);
    CFTypeRef pairs = IORegistryEntryCreateCFProperty(dev, CFSTR(kIOHIDDeviceUsagePairsKey), kCFAllocatorDefault, 0);
    CFTypeRef product = IORegistryEntryCreateCFProperty(dev, CFSTR(kIOHIDProductKey), kCFAllocatorDefault, 0);
    bool is_builtin = builtin && CFGetTypeID(builtin) == CFBooleanGetTypeID() && CFBooleanGetValue(builtin);
    bool is_trackpad = product && CFGetTypeID(product) == CFStringGetTypeID() &&
        CFStringFind(product, CFSTR("Trackpad"), kCFCompareCaseInsensitive).location != kCFNotFound;
    if (!is_builtin && !is_trackpad && pairs && CFGetTypeID(pairs) == CFArrayGetTypeID()) {
        // Generic Desktop / Mouse, excluding digitizer touchpads (page 0x0D usage 0x05)
        result = has_usage(pairs, 0x01, 0x02) && !has_usage(pairs, 0x0D, 0x05);
    }
    if (builtin) CFRelease(builtin);
    if (pairs) CFRelease(pairs);
    if (product) CFRelease(product);
    return result;
}

static bool mouse_present(void) {
    io_iterator_t it;
    if (IOServiceGetMatchingServices(kIOMainPortDefault, IOServiceMatching(kIOHIDDeviceKey), &it) != KERN_SUCCESS) return false;
    bool found = false;
    io_service_t dev;
    while ((dev = IOIteratorNext(it))) {
        if (!found && is_external_mouse(dev)) found = true;
        IOObjectRelease(dev);
    }
    IOObjectRelease(it);
    return found;
}

static void apply(void) {
    int present = mouse_present();
    if (present == last_mouse_present) return;
    last_mouse_present = present;
    bool want_natural = !present;
    if (get_natural() != want_natural) set_natural(want_natural);
    log_msg(present ? "mouse connected: scroll direction set to reverse"
                    : "no mouse: scroll direction set to natural");
}

static void timer_fired(CFRunLoopTimerRef timer, void *info) {
    pending = NULL;
    apply();
}

// Registry changes arrive in bursts and terminated devices linger briefly, so
// wait a moment before re-checking.
static void schedule_apply(void) {
    if (pending) return;
    pending = CFRunLoopTimerCreate(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent() + 1.5, 0, 0, 0, timer_fired, NULL);
    CFRunLoopAddTimer(CFRunLoopGetCurrent(), pending, kCFRunLoopDefaultMode);
    CFRelease(pending);
}

static void devices_changed(void *refcon, io_iterator_t it) {
    io_service_t dev;
    while ((dev = IOIteratorNext(it))) IOObjectRelease(dev);
    schedule_apply();
}

int main(int argc, char **argv) {
    if (!load_scroll_functions()) {
        fprintf(stderr, "scroll-switch: macOS scroll-direction functions not found\n");
        return 2;
    }
    if (argc > 1 && strcmp(argv[1], "status") == 0) {
        printf("mouse connected: %s\nscroll direction: %s\n", mouse_present() ? "yes" : "no", get_natural() ? "natural" : "reverse");
        return 0;
    }

    IONotificationPortRef port = IONotificationPortCreate(kIOMainPortDefault);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), IONotificationPortGetRunLoopSource(port), kCFRunLoopDefaultMode);
    io_iterator_t added, removed;
    IOServiceAddMatchingNotification(port, kIOFirstMatchNotification, IOServiceMatching(kIOHIDDeviceKey), devices_changed, NULL, &added);
    devices_changed(NULL, added);
    IOServiceAddMatchingNotification(port, kIOTerminatedNotification, IOServiceMatching(kIOHIDDeviceKey), devices_changed, NULL, &removed);
    devices_changed(NULL, removed);

    apply();
    CFRunLoopRun();
    return 0;
}
