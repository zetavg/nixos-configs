App.welcome = App.cable.subscriptions.create('HelloChannel', {
  connected: function () {
    const messagesSatausElement = document.getElementById('messages-sataus')
    if (messagesSatausElement) messagesSatausElement.innerText = 'connected'
  },
  disconnected: function () {
    const messagesSatausElement = document.getElementById('messages-sataus')
    if (messagesSatausElement) messagesSatausElement.innerText = 'disconnected'
  },
  received: function (data) {
    console.log(data)

    const messagesPlaceholderElement = document.getElementById('messages-placeholder')
    if (messagesPlaceholderElement) messagesPlaceholderElement.remove()

    const { time, ip, message = 'No message' } = data
    const html = `<em>${ip}:</em> ${message} <em>(${time})</em><br/>`
    const messagesTitleElement = document.getElementById('messages-title')
    if (messagesTitleElement) messagesTitleElement.insertAdjacentHTML('afterEnd', html)
  },
})
