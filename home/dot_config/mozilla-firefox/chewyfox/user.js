// vim:

//
//
// ~/.config/mozilla/firefox/chewyfox/user.js
//
//

//
// https://searchfox.org/
//

// Load chrome/userChrome.css and chrome/userContent.css
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Backup
//user_pref("browser.backup.location", "~/app/firefox/"); // Local path
//user_pref("browser.backup.preferences.ui.enabled", true);

// Bookmarks
//user_pref("browser.bookmarks.defaultLocation", "toolbar_____");
//user_pref("browser.bookmarks.max_backups", 150);
user_pref("browser.bookmarks.openInTabClosesMenu", false);
user_pref("browser.bookmarks.showMobileBookmarks", true);
//user_pref("browser.bookmarks.autoExportHTML", true);
//user_pref("browser.bookmarks.file", "~/net/rclone/firefox/bookmarks_latest.html"); // Local path
user_pref("browser.toolbars.bookmarks.visibility", "never");

// Cache 
//user_pref("browser.cache.disk.capacity", 4194304); // Size in KB
//user_pref("browser.cache.disk.smart_size.enabled", false);

// DevTools
user_pref("devtools.chrome.enabled", true);

// Download
user_pref("browser.download.alwaysOpenPanel", false);
user_pref("browser.download.autohideButton", false);
user_pref("browser.download.dir", "~/net/firefox"); // Local path
user_pref("browser.download.folderList", 2); // 2 => Download directory: `browser.download.dir`
user_pref("browser.download.force_save_internally_handled_attachments", true);
user_pref("browser.download.panel.shown", true); // Download panel has been shown
user_pref("browser.download.save_converter_index", 1);
user_pref("browser.download.viewableInternally.typeWasRegistered.avif", true);
user_pref("browser.download.viewableInternally.typeWasRegistered.webp", true);

// Extensions
user_pref("browser.discovery.enabled", false);
user_pref("extensions.webextensions.restrictedDomains", "");           // Allow extensions on restricted sites
user_pref("privacy.resistFingerprinting.block_mozAddonManager", true); // Allow extensions on restricted sites

// Input
user_pref("browser.ctrlTab.sortByRecentlyUsed", true);
user_pref("browser.gesture.swipe.left", "");  // Don't navigate tab history with swipe
user_pref("browser.gesture.swipe.right", ""); // Don't navigate tab history with swipe

// Search
user_pref("browser.search.context.loadInBackground", true);
user_pref("browser.search.region", "AU");
user_pref("browser.search.serpEventTelemetryCategorization.regionEnabled", false);
user_pref("browser.search.suggest.enabled.private", true);
user_pref("browser.search.totalSearches", 101);
user_pref("browser.search.update", false);

// Theme
user_pref("browser.active_color.dark", "#E0E8FF");
user_pref("browser.display.foreground_color", "#e0e8ff");
user_pref("browser.display.background_color", "#03030b");
user_pref("browser.display.background_color.dark", "#03030b");

user_pref("browser.translations.alwaysTranslateLanguages", "ru,zh-Hans");
user_pref("browser.translations.mostRecentTargetLanguages", "en");
user_pref("browser.translations.panelShown", true);




// Miscellaneous
user_pref("browser.aboutConfig.showWarning", false);
user_pref("browser.aboutwelcome.enabled", false);
user_pref("browser.bookmarks.restore_default_bookmarks", false);
user_pref("browser.bookmarks.editDialog.confirmationHintShowCount", 3);
user_pref("browser.contentanalysis.enabled", true);
user_pref("browser.contentblocking.category", "standard");
user_pref("browser.contentblocking.report.hide_vpn_banner", true);
user_pref("browser.engagement.ctrlTab.has-used", true);
user_pref("browser.eme.ui.firstContentShown", true);
user_pref("browser.engagement.downloads-button.has-used", true);
user_pref("browser.engagement.fxa-toolbar-menu-button.has-used", true);
user_pref("browser.engagement.library-button.has-used", true);
user_pref("browser.engagement.sidebar-button.has-used", true);
user_pref("browser.firefox-view.feature-tour", "{\"screen\":\"\",\"complete\":true}");
user_pref("browser.firefox-view.view-count", 2);
user_pref("browser.ipProtection.added", true);
user_pref("browser.ipProtection.enabled", true);
user_pref("browser.ipProtection.entitlementCache", "");
user_pref("browser.ipProtection.everOpenedPanel", true);
user_pref("browser.ipProtection.locationButtonBadgeDismissed", true);
user_pref("browser.ipProtection.openedPanelWithLocation", true);
user_pref("browser.ipProtection.stateCache", "unauthenticated");
user_pref("browser.ipProtection.usageCache", "");
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);
user_pref("browser.newtabpage.activity-stream.discoverystream.locale-weather-config", "en-CA, en-GB, en-US, pt-BR, es-AR, es-CL, es-MX");
user_pref("browser.newtabpage.activity-stream.discoverystream.region-weather-config", "BR, AR, CL, CO, EC, MX, AU, NZ, ZA");
user_pref("browser.newtabpage.activity-stream.newtabWallpapers.user.enabled", true);
user_pref("browser.newtabpage.activity-stream.newtabWallpapers.user.enabled.migrated", true);
user_pref("browser.newtabpage.activity-stream.newtabWallpapers.wallpaper", "dark-blue");
user_pref("browser.newtabpage.activity-stream.section.highlights.includeBookmarks", false);
user_pref("browser.newtabpage.activity-stream.showSearch", false);
user_pref("browser.newtabpage.activity-stream.showSearch", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredCheckboxes", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.showWeather", false);
user_pref("browser.newtabpage.activity-stream.testing.shouldInitializeFeeds", false);
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.pagethumbnails.capturing_disabled", true);
user_pref("browser.profiles.created", true);
user_pref("browser.profiles.profile-copied", true);
user_pref("browser.profiles.profile-name.updated", true);
user_pref("browser.protections_panel.infoMessage.seen", true);
user_pref("browser.proton.toolbar.version", 3);
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.startup.couldRestoreSession.count", 2);
user_pref("browser.startup.page", 3);
user_pref("browser.startup.upgradeDialog.enabled", true);
user_pref("browser.tabs.allowTabDetach", false);
user_pref("browser.tabs.closeWindowWithLastTab", false);
user_pref("browser.tabs.groups.smart.userEnabled", false);
user_pref("browser.tabs.hoverPreview.showThumbnails", false);
user_pref("browser.tabs.inTitlebar", 1);
user_pref("browser.tabs.loadBookmarksInBackground", true);
user_pref("browser.tabs.loadBookmarksInTabs", true);
user_pref("browser.tabs.splitview.hasUsed", true);
user_pref("browser.termsofuse.prefMigrationCheck", true);
user_pref("browser.theme.toolbar-theme", 0);
user_pref("browser.toolbarbuttons.introduced.sidebar-button", true);
user_pref("browser.urlbar.quicksuggest.scenario", "history");
user_pref("browser.urlbar.quickactions.timesShownOnboardingLabel", 3);
user_pref("browser.urlbar.tipShownCount.searchTip_onboard", 4);
user_pref("browser.urlbar.tipShownCount.searchTip_redirect", 4);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.policy.dataSubmissionPolicyAccepted", false);
user_pref("datareporting.policy.dataSubmissionPolicyBypassNotification", true);
user_pref("datareporting.usage.uploadEnabled", false);
user_pref("devtools.accessibility.enabled", false);
