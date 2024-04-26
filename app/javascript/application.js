// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"


// Borrowed from Bulma documentation, to make the burger menu work
document.addEventListener('DOMContentLoaded', () => {

  // Get all "navbar-burger" elements
  const $navbarBurgers = Array.prototype.slice.call(document.querySelectorAll('.navbar-burger'), 0);

  // Add a click event on each of them
  $navbarBurgers.forEach( el => {
    el.addEventListener('click', () => {

      // Get the target from the "data-target" attribute
      const target = el.dataset.target;
      const $target = document.getElementById(target);

      // Toggle the "is-active" class on both the "navbar-burger" and the "navbar-menu"
      el.classList.toggle('is-active');
      $target.classList.toggle('is-active');

    });
  });

});

// Borrowed from Bulma documentation, to make the notification close button work
document.addEventListener('turbo:load', () => {
  (document.querySelectorAll('.notification .delete') || []).forEach(($delete) => {
    const $notification = $delete.parentNode;

    $delete.addEventListener('click', () => {
      $notification.parentNode.removeChild($notification);
    });
  });
});

window.navigateBackOrUp = function() {
  if (history.length > 2) {
      // If history is not empty, go back
      history.back();
  } else {
    // If history is empty, modify the URL to remove the last segment and go there
    let newLocation = window.location.href.replace(/\/\d+\D*$/,'');
    if (newLocation === window.location.href) {
      // If the URL didn't change, go up one level
      newLocation = window.location.href.replace(/\/[^\/]+$/,'');
    }
    window.location.href = newLocation;
  }
}

document.addEventListener('turbo:load', () => {
  document.querySelector('.filter-input')?.focus();
});
