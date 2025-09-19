import 'package:flutter/material.dart';

import 'app_info.dart';

const Map<String, Color> categoryColors = {
  "Social": Colors.blue,
  "Productivity": Colors.green,
  "Finance": Colors.orange,
  "Entertainment": Colors.purple,
  "Shopping": Colors.brown,
  "Internet": Colors.pink,
  "Utility": Colors.teal,
};

const Map<String, AppInfo> usageWhitelist = {
  // Social
  "com.instagram.android": AppInfo(name: "Instagram", category: "Social"),
  "com.whatsapp": AppInfo(name: "WhatsApp", category: "Social"),
  "com.facebook.katana": AppInfo(name: "Facebook", category: "Social"),
  "com.snapchat.android": AppInfo(name: "Snapchat", category: "Social"),
  "com.twitter.android": AppInfo(name: "X (Twitter)", category: "Social"),
  "com.reddit.frontpage": AppInfo(name: "Reddit", category: "Social"),
  "com.google.android.youtube": AppInfo(name: "YouTube", category: "Social"),
  "com.discord": AppInfo(name: "Discord", category: "Social"),
  "com.linkedin.android": AppInfo(name: "LinkedIn", category: "Social"),
  "com.pinterest": AppInfo(name: "Pinterest", category: "Social"),
  "com.telegram.messenger": AppInfo(name: "Telegram", category: "Social"),
  "org.thoughtcrime.securesms": AppInfo(name: "Signal", category: "Social"),
  "com.tumblr": AppInfo(name: "Tumblr", category: "Social"),
  "com.tencent.mm": AppInfo(name: "WeChat", category: "Social"),
  "com.viber.voip": AppInfo(name: "Viber", category: "Social"),
  "com.kakao.talk": AppInfo(name: "KakaoTalk", category: "Social"),
  "com.clubhouse.app": AppInfo(name: "Clubhouse", category: "Social"),

  // Productivity
  "com.microsoft.teams": AppInfo(
    name: "Microsoft Teams",
    category: "Productivity",
  ),
  "com.microsoft.office.outlook": AppInfo(
    name: "Outlook",
    category: "Productivity",
  ),
  "com.slack": AppInfo(name: "Slack", category: "Productivity"),
  "com.google.android.gm": AppInfo(name: "Gmail", category: "Productivity"),
  "com.google.android.calendar": AppInfo(
    name: "Google Calendar",
    category: "Productivity",
  ),
  "com.google.android.keep": AppInfo(
    name: "Google Keep",
    category: "Productivity",
  ),
  "com.evernote": AppInfo(name: "Evernote", category: "Productivity"),
  "com.todoist": AppInfo(name: "Todoist", category: "Productivity"),
  "com.ticktick.task": AppInfo(name: "TickTick", category: "Productivity"),
  "com.asana.app": AppInfo(name: "Asana", category: "Productivity"),
  "com.trello": AppInfo(name: "Trello", category: "Productivity"),
  "com.notion.android": AppInfo(name: "Notion", category: "Productivity"),
  "com.dropbox.android": AppInfo(name: "Dropbox", category: "Productivity"),
  "com.google.android.apps.docs": AppInfo(
    name: "Google Drive",
    category: "Productivity",
  ),
  "com.adobe.reader": AppInfo(name: "Adobe Acrobat", category: "Productivity"),

  // Finance
  "com.google.android.apps.nbu.paisa.user": AppInfo(
    name: "Google Pay",
    category: "Finance",
  ),
  "com.phonepe.app": AppInfo(name: "PhonePe", category: "Finance"),
  "net.one97.paytm": AppInfo(name: "Paytm", category: "Finance"),
  "com.mint": AppInfo(name: "Mint", category: "Finance"),
  "com.paypal.android.p2pmobile": AppInfo(name: "PayPal", category: "Finance"),
  "com.icici.bank.imobile": AppInfo(name: "iMobile Pay", category: "Finance"),
  "com.axis.mobile": AppInfo(name: "Axis Mobile", category: "Finance"),
  "com.dbs.mbanking": AppInfo(name: "DBS Bank", category: "Finance"),

  // Entertainment
  "com.netflix.mediaclient": AppInfo(
    name: "Netflix",
    category: "Entertainment",
  ),
  "com.spotify.music": AppInfo(name: "Spotify", category: "Entertainment"),
  "com.primevideo": AppInfo(
    name: "Amazon Prime Video",
    category: "Entertainment",
  ),
  "in.startv.hotstar": AppInfo(
    name: "Disney+ Hotstar",
    category: "Entertainment",
  ),
  "com.sonyliv": AppInfo(name: "SonyLIV", category: "Entertainment"),
  "com.zee5": AppInfo(name: "ZEE5", category: "Entertainment"),
  "com.hulu.plus": AppInfo(name: "Hulu", category: "Entertainment"),
  "tv.twitch.android.app": AppInfo(name: "Twitch", category: "Entertainment"),
  "com.audible.application": AppInfo(
    name: "Audible",
    category: "Entertainment",
  ),

  // Internet
  "com.android.chrome": AppInfo(name: "Chrome", category: "Internet"),
  "org.mozilla.firefox": AppInfo(name: "Firefox", category: "Internet"),
  "com.microsoft.emmx": AppInfo(name: "Edge", category: "Internet"),
  "com.opera.browser": AppInfo(name: "Opera", category: "Internet"),
  "com.brave.browser": AppInfo(name: "Brave", category: "Internet"),
  "com.sec.android.app.sbrowser": AppInfo(name: "Samsung Internet", category: "Internet"),
  "com.duckduckgo.mobile.android": AppInfo(
    name: "DuckDuckGo",
    category: "Internet",
  ),
  "com.android.browser": AppInfo(name: "Android Browser", category: "Internet"),

  // Shopping
  "com.amazon.mShop.android.shopping": AppInfo(
    name: "Amazon Shopping",
    category: "Shopping",
  ),
  "com.flipkart.android": AppInfo(name: "Flipkart", category: "Shopping"),

  // Utility
  "com.google.android.apps.maps": AppInfo(
    name: "Google Maps",
    category: "Utility",
  ),
  "com.ubercab": AppInfo(name: "Uber", category: "Utility"),
  "com.olacabs.customer": AppInfo(name: "Ola Cabs", category: "Utility"),
};
