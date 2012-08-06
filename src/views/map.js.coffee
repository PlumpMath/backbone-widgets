#= require gmaps

class Backbone.Widgets.Map extends Backbone.View
  markers: []
  tagName: 'div'
  className: 'map'
  attributes:
    id: 'gmaps'

  initialize: (opts) =>
    @lat = opts.lat
    @lng = opts.lng
    @el = opts.el
    @markersOpts = opts.markers
    @collection = opts.collection
    @collection.on 'reset', @renderMarkers

  render: =>
    @gmap = new GMaps
      div: @$el.attr('id')
      lat: @lat
      lng: @lng
      zoom_changed: @updateCollection
      dragend: @updateCollection

    @renderMarkers()
    @

  renderMarkers: =>
    _(@markers).each (marker) =>
      marker.close()
    @markers = []

    @collection.each (marker) =>
      opts =
        title: marker.getTitle()
        lat: marker.getLatitude()
        lng: marker.getLongitude()
        color: if marker instanceof TurnYourTime.Models.Offer
                 'red'
               else
                 'blue'
        map: @

      marker = new Backbone.Widgets.MapMarker opts
      marker.render()
      @markers.push marker

  updateCollection: =>
    @collection.fetch
      data:
        bounds: @getBounds()

  getBounds: =>
    bounds = @gmap.map.getBounds()

    lats = [ bounds.getNorthEast().lat(),
             bounds.getSouthWest().lat() ]
    lngs = [ bounds.getNorthEast().lng(),
             bounds.getSouthWest().lng() ]

    return {
      min_lat: _(lats).min()
      min_lng: _(lngs).min()
      max_lat: _(lats).max()
      max_lng: _(lngs).max()
    }
