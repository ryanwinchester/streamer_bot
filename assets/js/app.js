import "phoenix_html"
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

window.addEventListener("phx:exploding-items", (event) => {
  // For now, we cap the number of bits to 150. In the future we can add some
  // special styles for larger bit amounts.
  let count = Number(event.detail.count);
  count = count > 150 ? 150 : count;

  for (let i = 0; i < 5; i++) {
    for (let j = 0; j < count; j++) {
      createExplodingImage(event.detail.img_src);
    }
  }
});

/**
 * Create an image at a random location across the top, with a random
 * animation delay.
 *
 * @param {string} src - The src uri of the image.
 */
function createFallingImage(src) {
  const imageContainer = document.getElementById('falling-items-container');
  const image = document.createElement('img');
  image.src = src;
  image.style.position = 'absolute';
  image.style.top = '0';
  image.style.left = `${Math.random() * 100}%`;
  image.classList.add('falling-animation');
  image.style.animationDelay = `${Math.random() * 5}s`;

  imageContainer.appendChild(image);

  // Remove the image from the DOM when the animation is finished.
  image.addEventListener('animationend', () => {
    imageContainer.removeChild(image);
  });
}

/**
 * Create an image that explodes outwards.
 *
 * @param {string} src - The src uri of the image.
 */
function createExplodingImage(src) {
  const imageContainer = document.getElementById('exploding-items-container');
  const image = document.createElement('img');
  image.src = src;
  image.classList.add('explode-animation');
  image.style.animationName = 'explode';
  image.style.animationDuration = `${1 + Math.random() * 2}s`;

  // Calculate random direction and distance
  const angle = Math.random() * 360; // Angle in degrees
  const distance = 100 + Math.random() * 1920; // Distance in pixels
  const radians = angle * Math.PI / 180;
  const translateX = Math.cos(radians) * distance;
  const translateY = Math.sin(radians) * distance;

  // Set CSS variables for translation
  image.style.setProperty('--translateX', `${translateX}px`);
  image.style.setProperty('--translateY', `${translateY}px`);

  imageContainer.appendChild(image);

  // Remove the image from the DOM when the animation is finished.
  image.addEventListener('animationend', () => {
    imageContainer.removeChild(image);
  });
}

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
