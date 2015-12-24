apis = [
  'v2/sdk/engine/server'
  'v2/sdk/tpsConnectors'
  'v2/sdk/authenticationTest'
  'v2/sdk/devices/:token/locations/bulk'
  'v2/sdk/devices'

  'v2/sdk/devices/123456/tags/bulk'
  'v2/sdk/devices/654321/tags/bulk'

  'v2/sdk/devices/123/uservars'
  'v2/sdk/devices/321/uservars'

  'v2/sdk/devices/123/alias'
  'v2/sdk/devices/321/alias'

  'v2/sdk/stats/messageClicks'
  'v2/sdk/geoFenceTriggers'

  'v2/sdk/geoFenceTriggers/123456/events'
  'v2/sdk/geoFenceTriggers/654321/events'

  'v2/open/engine/authenticationTest'
  'v2/open/engine/events'

  'v2/open/engine/channels/aaa'
  'v2/open/engine/channels/bbb'

  'v2/open/engine/channels/aaa/userIds'
  'v2/open/engine/channels/bbb/userIds'

  'v2/open/engine/messages'

  'v2/partner/authenticationTest'
  'v2/partner/apps'

  'v2/partner/apps/:appId1/messages'
  'v2/partner/apps/:appId2/messages'

  'v2/partner/apps/:appId3/geoFences'
  'v2/partner/apps/:appId4/geoFences'

  'v2/partner/apps/:appId1/geoFences/:geoFenceId1'
  'v2/partner/apps/:appId1/geoFences/:geoFenceId2'
  'v2/partner/apps/:appId2/geoFences/:geoFenceId1'
  'v2/partner/apps/:appId2/geoFences/:geoFenceId2'

]

urlPattern = [
  'v2/sdk/devices/:token/locations/bulk'
  'v2/sdk/devices/:token/tags/bulk'
  'v2/sdk/devices/:token/uservars'
  'v2/sdk/devices/:token/alias'

  'v2/sdk/geoFenceTriggers/:geoFenceTriggerId'
  'v2/sdk/geoFenceTriggers/:geoFenceTriggerId/events'

  'v2/open/engine/channels/:channelName'
  'v2/open/engine/channels/:channelName/userIds'

  'v2/partner/apps/:appId/messages'
  'v2/partner/apps/:appId/geoFences'
  'v2/partner/apps/:appId/geoFences/:geoFenceId'
]













formatUrlPath = (urlPath) ->
  return urlPath if urlPath.match('v1')?

  # urlPath contain v2/sdk/devices, need to remove token.
  if urlPath.match 'v2/sdk/devices'
    formatDevicesUrl urlPath
  else if urlPath.match 'v2/sdk/geoFenceTriggers'
    formatGeoFenceTriggersUrl urlPath
  else if urlPath.match 'v2/open/engine/channels'
    formatChannelsUrl urlPath
  else if urlPath.match 'v2/partner/apps'
    formatAppsUrl urlPath
  else
    urlPath

formatDevicesUrl = (urlPath) ->
  reg = new RegExp("^devices")
  if reg.test urlPath
    urlPath
  else
    names = urlPath.split '/'
    names[3] = ':token'
    urlPath = names.toString().replace new RegExp(',',"gm"), '/'

formatGeoFenceTriggersUrl = (urlPath) ->
  reg = new RegExp("^geoFenceTriggers")
  if reg.test urlPath
    urlPath
  else
    names = urlPath.split '/'
    names[3] = ':geoFenceTriggerId'
    urlPath = names.toString().replace new RegExp(',',"gm"), '/'

formatChannelsUrl = (urlPath) ->
  names = urlPath.split '/'
  names[4] = ':channelName'
  urlPath = names.toString().replace new RegExp(',',"gm"), '/'

formatAppsUrl = (urlPath) ->
  reg = new RegExp("^apps")
  if reg.test urlPath
    urlPath
  else
    names = urlPath.split '/'
    names[3] = ':appId'
    names[5] = ':geoFenceId' if names[5]?
    urlPath = names.toString().replace new RegExp(',',"gm"), '/'

store = {}

apis.map (api) ->
  store[formatUrlPath api] ?= { count: 0 }
  store[formatUrlPath api].count += 1

console.log store
