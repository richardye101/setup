There are two things to setup for firefox:

1. userChrome.css
2. Sidebery Styles

## userChrome Setup

1. Download the `chrome` folder
2. Navigate to `about:support` and Ctrl+F for "Profile Folder"
3. Open the profile folder and paste the downloaded `chrome` folder into the "Profile Folder"
4. Navigate to `about:config`, search for userprof, and switch `toolkit.legacyUserProfileCustomizations.stylesheets` to `true`
	- Instructions from [this website](https://www.userchrome.org/how-create-userchrome-css.html)
5. Restart Firefox

## Sidebery Setup

>Updated as of May 8th, 2023

1. Navigate to https://github.com/mbnuqw/sidebery and install the beta version (5.0.0b31) at this link:
	- https://github.com/mbnuqw/sidebery/releases/download/v5.0.0b31/sidebery-5.0.0b31.xpi
2. Download the `sidebery-data-*.json` file
3. Open Sidebery settings from the Extensions in Firefox
4. Scroll to the `Help` section
5. Click `Import addon Data` 
