// Click-to-play videos: each poster is a normal link to YouTube, replaced by the player only when clicked,
// so nothing loads from YouTube until a visitor asks for it. Pages opened from disk keep the plain link,
// because YouTube's player refuses to run without a web address to report.
if (location.protocol !== 'file:') {
  for (const link of document.querySelectorAll('a[data-youtube-id]')) {
    link.addEventListener('click', event => {
      if (event.button !== 0 || event.ctrlKey || event.metaKey || event.shiftKey || event.altKey) return;
      event.preventDefault();
      const player = document.createElement('iframe');
      player.src = `https://www.youtube-nocookie.com/embed/${encodeURIComponent(link.dataset.youtubeId)}?autoplay=1&rel=0`;
      player.title = link.dataset.title || 'Video';
      player.allow = 'autoplay; encrypted-media; picture-in-picture; fullscreen';
      player.allowFullscreen = true;
      player.referrerPolicy = 'strict-origin-when-cross-origin';
      link.replaceWith(player);
      player.focus();
    });
  }
}
