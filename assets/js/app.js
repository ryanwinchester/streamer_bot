// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let liveSocket = new LiveSocket("/live", Socket, {
  params: {_csrf_token: csrfToken}
});

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

window.addEventListener("phx:falling-items", (event) => {
  // For now, we cap the number of bits to 150. In the future we can add some
  // special styles for larger bit amounts.
  let count = Number(event.detail.count);
  count = count > 150 ? 150 : count;

  for (let i = 0; i < count; i++) {
    createFallingImage(event.detail.img_src);
  }
});

/**
 * Create an image at a random location across the top, with a random
 * animation delay.
 *
 * @param {string} src - The src uri of the image.
 */
function createFallingImage(src) {
  const image = document.createElement('img');
  image.src = src;
  image.style.position = 'absolute';
  image.style.top = '0';
  image.style.left = `${Math.random() * 100}%`;
  image.classList.add('falling-animation');
  image.style.animationDelay = `${Math.random() * 5}s`;

  document.getElementById('falling-items-container').appendChild(image);
}

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
