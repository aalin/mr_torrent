function getSocketToken() {
  const meta = document.querySelector('meta[name=socket_token]');
  return meta && meta.content;
}

function startApp() {
  const socketToken = getSocketToken();

  if (!socketToken) {
    return;
  }

  const socket = new Phoenix.Socket("/socket", { params: { token: socketToken } })
  socket.connect();

  const torrentChannels = new Map()

  for (let elem of document.querySelectorAll('[data-torrent-id]')) {
    const torrentId = parseInt(elem.dataset.torrentId, 10)

    setupChannel(socket, torrentChannels, torrentId)
  }
}

function setupChannel(socket, channels, torrentId) {
  if (channels.has(torrentId)) {
    return
  }

  const channel = socket.channel(`torrent:${torrentId}`)
  channels.set(torrentId, channel)
  channel.join()

  channel.on('update_fields', (message) => {
    for (let [fieldName, value] of Object.entries(message)) {
      for (let elem of queryTorrentField(torrentId, fieldName)) {
        elem.innerText = value
      }
    }
  });
}

function queryTorrentField(torrentId, fieldName) {
  return document.querySelectorAll(`[data-torrent-id="${torrentId}"][data-torrent-field="${fieldName}"]`)
}

window.addEventListener('load', startApp)
