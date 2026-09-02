config.load_autoconfig(False)

c.qt.force_platform = "xcb"

c.spellcheck.languages = ['en-US']

bg0 = "#0d0d0d"
bg1 = "#0f0f0f"
page_bg = "#0b0b0b"
tab_even = "#363635"
tab_odd = "#3b3b3a"
accent = "#465b8a"

c.colors.webpage.bg = page_bg

c.completion.height = "26%"
c.colors.completion.even.bg = bg0
c.colors.completion.odd.bg = bg1
c.colors.completion.category.bg = bg1
c.colors.completion.match.fg = accent
c.colors.completion.item.selected.bg = accent
c.colors.completion.item.selected.border.top = accent
c.colors.completion.item.selected.border.bottom = accent

c.colors.statusbar.command.bg = bg0
c.colors.statusbar.command.private.bg = bg0
c.colors.statusbar.insert.bg = tab_odd
c.colors.statusbar.private.bg = "black"
c.colors.statusbar.url.fg = "grey"
c.colors.statusbar.url.success.https.fg = "white"

c.tabs.indicator.width = 0
c.colors.tabs.even.bg = tab_even
c.colors.tabs.odd.bg = tab_odd
c.colors.tabs.selected.even.bg = bg0
c.colors.tabs.selected.odd.bg = bg0
c.tabs.title.format = "{private}{audio}{index}: {current_title}"

c.url.start_pages = ["about:blank"]
c.url.default_page = "about:blank"
c.url.searchengines = {
    "DEFAULT": "https://www.google.com/search?hl=en&q={}",
    "ddg": "https://duckduckgo.com/?q={}",
    "gh": "https://github.com/search?q={}",
    "aw": "https://wiki.archlinux.org/index.php?search={}",
    "fw": "https://fedoraproject.org/wiki/Special:Search?search={}",
    "w": "https://en.wikipedia.org/w/index.php?search={}",
    "ma": "https://www.metal-archives.com/search?searchString={}",
}

c.editor.command = [
    "foot",
    "nvim",
    "{file}",
    "-c",
    "normal {line}G{column0}l",
]
c.zoom.default = "120%"
c.confirm_quit = ["downloads"]
c.content.autoplay = False
# c.content.pdfjs = True

config.bind("h", "tab-prev")
config.bind("l", "tab-next")
config.bind("J", "scroll right")
config.bind("K", "scroll left")
config.bind("e", "cmd-set-text :open {url:pretty}")

config.bind("zp", "open -p about:blank")

proxy_show = "set content.proxy?"
proxy_toggle = (
    "config-cycle -t content.proxy "
    "socks://127.0.0.1:12334/ none --print"
)
for key in ("P", "["):
    config.bind(key, proxy_show)
for key in ("<Ctrl-Shift-p>", "<Ctrl-[>"): # <Ctrl-[> doesn't work, idk why
    config.bind(key, proxy_toggle)

for key, command in {
    "]": "cmd-set-text -s :open -t",
    "ه": "mode-enter insert",
    "ا": "tab-prev",
    "ت": "scroll down",
    "ن": "scroll up",
    "م": "tab-next",
    "ة": "scroll right",
    "»": "scroll left",
    "آ": "back",
    "«": "forward",
    "ب": "hint",
    "ث": "cmd-set-text :open {url:pretty}",
    "خ": "cmd-set-text -s :open",
    "ی": "tab-close",
    "ق": "reload",
    "ع": "undo",
    "ظح": "open -p about:blank",
}.items():
    config.bind(key, command)
