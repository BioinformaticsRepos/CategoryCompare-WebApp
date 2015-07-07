$(loadCy = function () {
  options = {
    layout: {
      name: 'arbor',
      liveUpdate: true, // whether to show the layout as it's running
      ready: undefined, // callback on layoutready 
      stop: undefined, // callback on layoutstop
      maxSimulationTime: 4000, // max length in ms to run the layout
      fit: true, // reset viewport to fit default simulationBounds
      padding: [ 50, 50, 50, 50 ], // top, right, bottom, left
      simulationBounds: undefined, // [x1, y1, x2, y2]; [0, 0, width, height] by default
      ungrabifyWhileSimulating: true, // so you can't drag nodes during layout

      // forces used by arbor (use arbor default on undefined)
      repulsion: undefined,
      stiffness: undefined,
      friction: undefined,
      gravity: true,
      fps: undefined,
      precision: undefined,

      // static numbers or functions that dynamically return what these
      // values should be for each element
      nodeMass: undefined, 
      edgeLength: undefined,

      stepSize: 1, // size of timestep in simulation

      // function that returns true if the system is stable to indicate
      // that the layout can be stopped
      stableEnergy: function( energy ){
        var e = energy; 
        return (e.max <= 0.5) || (e.mean <= 0.3);
      }
    },

    showOverlay: false,
    style: cytoscape.stylesheet()
    .selector('node')
    .css({
        'content': 'data(name)',
        'font-family': 'helvetica',
        'font-size': 4,
        'min-zoomed-font-size':5,
        'text-outline-width': 0,
        'text-outline-color': '#888',
        'text-valign': 'center',
        'color': '#fff',
        'width': 'mapData(weight, 30, 80, 20, 50)',
        'height': 'mapData(height, 0, 200, 10, 45)',
        'border-color': '#fff'
    })
    .selector(':selected')
    .css({
        'background-color': '#000',
        'line-color': '#000',
        'target-arrow-color': '#000',
        'text-outline-color': '#000'
    })
    .selector('edge')
    .css({
        'width': 2,
        'target-arrow-shape': 'none',
        'curve-style': 'bezier'
    }),

    elements: gon.elements,

    ready: function () {
      cy = this;
    }
  };

  $('#cy').cytoscape(options);

});
