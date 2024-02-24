import { Controller } from "@hotwired/stimulus"

import * as eip55 from "eip55"

// Connects to data-controller="ethereum"
export default class extends Controller {
  connect() {
  }

  async signin() {
     // Request accounts from Metamask, using window.ethereum API
     let addresses = await window.ethereum.request({ method: 'eth_requestAccounts' });
     if (addresses.length === 0) {
       console.error('No address provided');
       return;
     }
     let address = addresses[0]; // TODO Add a picker here
     address = eip55.encode(address);

     let domain = window.location.host;
     const protocol = window.location.protocol;

     const nonce = getCookie('nonce');
     const timestamp = getCookie('timestamp').replaceAll("%3A",":");
     const message = `${domain} wants you to sign in with your Ethereum account:\n${address}\n\nLogging into EthBerlin Submißion portal\n\nURI: ${protocol}//${domain}\nVersion: 1\nChain ID: 1\nNonce: ${nonce}\nIssued At: ${timestamp}`;

     let signature = await siweSign(message, address);

     // Navigate to /sign_in with message and signature in the form params
     const form = document.createElement('form');
     form.method = 'POST';
     form.action = '/sign_in';
     form.style.display = 'none';

     const messageInput = document.createElement('textarea');
     messageInput.name = 'message';
     messageInput.value = message;
     form.appendChild(messageInput);

     const signatureInput = document.createElement('input');
     signatureInput.name = 'signature';
     signatureInput.value = signature;
     form.appendChild(signatureInput);

     document.body.appendChild(form);
     form.submit();
  }
}

function stringToHex(str) {
  const encoder = new TextEncoder(); // Create a TextEncoder instance
  const bytes = encoder.encode(str); // Encode the string as UTF-8 bytes
  let hex = '';
  for (const byte of bytes) {
      // Convert each byte to hexadecimal and pad with zeros if necessary
      hex += byte.toString(16).padStart(2, '0');
  }
  return hex;
}

function getCookie(name) {
  const value = `; ${document.cookie}`;
  const parts = value.split(`; ${name}=`);
  if (parts.length ===  2) return parts.pop().split(';').shift();
}

async function siweSign(siweMessage, account) {
  try {
      const msg = `0x${stringToHex(siweMessage)}`;
      console.log(msg);
      return ethereum.request({
        method: "personal_sign",
        params: [msg, account],
      });
  } catch (err) {
      console.error(err);
  }
};
