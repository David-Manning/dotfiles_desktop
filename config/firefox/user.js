// ~/software/dotfiles_desktop/firefox/user.js

// ---------------------------------------------------------
// Appearance
// ---------------------------------------------------------
// Tell Firefox the system uses a dark theme (1 = dark, 0 = light)
user_pref("ui.systemUsesDarkTheme", 1);
// Website appearance: 0 = dark, 1 = light, 2 = follow system, 3 = follow browser theme
user_pref("layout.css.prefers-color-scheme.content-override", 0);

// ---------------------------------------------------------
// AI and machine learning features off
// ---------------------------------------------------------
user_pref("browser.ai.control.default", "blocked");
user_pref("browser.ai.control.linkPreviewKeyPoints", "blocked");
user_pref("browser.ai.control.pdfjsAltText", "blocked");
user_pref("browser.ai.control.sidebarChatbot", "blocked");
user_pref("browser.ai.control.smartTabGroups", "blocked");
user_pref("browser.ai.control.smartWindow", "blocked");
user_pref("browser.ai.control.translations", "blocked");
user_pref("browser.ml.chat.enabled", false);
user_pref("browser.ml.chat.menu", false);
user_pref("browser.ml.chat.page", false);
user_pref("browser.ml.linkPreview.enabled", false);
user_pref("browser.ml.linkPreview.longPress", false);
user_pref("browser.smartwindow.memories.generateFromConversation", false);
user_pref("browser.smartwindow.memories.generateFromHistory", false);
user_pref("browser.tabs.groups.smart.enabled", false);
user_pref("browser.tabs.groups.smart.userEnabled", false);
user_pref("extensions.ml.enabled", false);
user_pref("pdfjs.enableAltText", false);
user_pref("browser.translations.enable", false);

// ---------------------------------------------------------
// New tab page: no stories, sponsored content or widgets
// ---------------------------------------------------------
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredCheckboxes", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.widgets.enabled", false);
user_pref("browser.newtabpage.activity-stream.widgets.clocks.enabled", false);
user_pref("browser.newtabpage.activity-stream.widgets.crossword.enabled", false);
user_pref("browser.newtabpage.activity-stream.widgets.focusTimer.enabled", false);
user_pref("browser.newtabpage.activity-stream.widgets.lists.enabled", false);
user_pref("browser.newtabpage.activity-stream.widgets.sportsWidget.enabled", false);
user_pref("browser.newtabpage.activity-stream.widgets.weather.enabled", false);

// ---------------------------------------------------------
// Privacy
// ---------------------------------------------------------
user_pref("privacy.globalprivacycontrol.enabled", true);
user_pref("privacy.clearOnShutdown_v2.formdata", true);
user_pref("network.dns.disablePrefetch", true);
user_pref("network.prefetch-next", false);
user_pref("network.http.speculative-parallel-limit", 0);
user_pref("signon.firefoxRelay.feature", "disabled");

// ---------------------------------------------------------
// Interface
// ---------------------------------------------------------
user_pref("browser.bookmarks.showMobileBookmarks", false);
user_pref("sidebar.visibility", "hide-on-close");
user_pref("sidebar.revamp.round-content-area", false);
user_pref("ui.key.menuAccessKeyFocuses", false);

// ---------------------------------------------------------
// Media
// ---------------------------------------------------------
// Allow DRM content (Netflix, Spotify etc.)
user_pref("media.eme.enabled", true);
