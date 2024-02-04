import datetime
import os
from urllib.parse import parse_qs, urlparse

import feedparser
import requests
from wikijs import WikiJS

wiki = WikiJS(
    url=os.getenv("WIKI_JS_API_URL"),
    token=os.getenv("WIKI_JS_API_TOKEN"),
)

self_hosted_domain: str = os.getenv("PIPED_API_DOMAIN")
channel_id: str = os.getenv("YOUTUBE_CHANNEL_ID")
api_urls: list[str] = [f"https://{self_hosted_domain}"]
link_replacements: list[str] = [os.getenv("PIPED_FRONTEND_DOMAIN"), "piped.video"]

content: str = f"*Updated: {datetime.datetime.now():%Y-%m-%d %I:%M:%S %p UTC}*\n"
for api_url in api_urls:
    feed = feedparser.parse(f"{api_url}/feed/unauthenticated/rss?channels={channel_id}")

    for entry in feed["entries"]:
        link: str = entry["link"]
        id: str = parse_qs(urlparse(link).query)["v"][0]

        youtube_link: str = link
        for replacement in link_replacements:
            youtube_link = youtube_link.replace(replacement, "youtube.com")

        req = requests.get(f"https://{self_hosted_domain}/streams/{id}")
        if req.json()["duration"] > 60 * 60 or req.json()["duration"] == 0:
            print(f"{entry['title']} - {youtube_link}")
            content += f"* [{entry['title']}]({youtube_link})\n"

wiki.update_page(id=2, content=content)
