Slash = require 'slash'

module.exports = class DuelBot
  constructor: (dispatch) ->
    slash = new Slash dispatch

    active = false
    dueler = name: ''
    start = true

    slash.on 'duel', (args) ->
      switch arg = args.split(' ')[0].toLowerCase()
        when 'start'
          active = true
          dispatch.toServer 'cDuelRequest',
            unkOffset: 26 + (dueler.name.length + 1) * 2
            unkCount: 0
            unk1: 12
            unk2: 0
            unk3: 0
            unk4: 0
            name: dueler.name
          slash.print '[DuelBot] Starting duels with: ' + dueler.name

        when 'stop'
          active = false
          slash.print '[DuelBot] Disabled.'

        else
          active = true
          dueler.name = arg
          slash.print '[DuelBot] Dueling partner set to: ' + dueler.name

    dispatch.hook 'sDuelDialog', (event) ->
      if active
        if event.senderName.toLowerCase() is dueler.name
          start = true
          dueler.id = event.senderId
          dispatch.toServer 'cDuelAccept',
            unk: event.unk2
            dialogId: event.dialogId
          return false

        if event.recipientName.toLowerCase() is dueler.name
          start = false
          dueler.id = event.recipientId
          return false

    dispatch.hook 'sPlayerRelation', (event) ->
      if active and dueler.id?.equals event.cid
        if event.relation is 5 and not start
          # /uncle
          dispatch.toServer new Buffer '0400A39E', 'hex'
          dispatch.toServer new Buffer '04009EC5', 'hex'
      return

    dispatch.hook 'sDuelResult', (event) ->
      if active and start
        dispatch.toServer 'cDuelRequest',
          unkOffset: 26 + (dueler.name.length + 1) * 2
          unkCount: 0
          unk1: 12
          unk2: 0
          unk3: 0
          unk4: 0
          name: dueler.name
      return
