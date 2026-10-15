/* Root's Cyber Warfare - Remote Access (Hackerman SSH) desktop app.
 *
 * Logs this computer into another one over the in-game network. Nothing is decided here: the server
 * owns the session, checks the route and the credentials against the target's own account list, and
 * answers on the rootcw_hack_ssh channel. Once a session is open every other Hackerman app reaches the
 * target's devices as well, because the server resolves the session when it builds a device list.
 *
 * ES5 on purpose, like the rest of the AE3 web UI, and no external assets: the CEF control cannot
 * resolve relative URLs out of a PBO.
 */
(function () {
  "use strict";

  // The bridge has no unsubscribe, so one listener fans out to whichever windows are open
  var sinks = [];

  if (window.RootCW_hackSshBound !== true) {
    window.RootCW_hackSshBound = true;

    A3.on("rootcw_hack_ssh", function (payload) {
      sinks.slice().forEach(function (sink) {
        try { sink(payload || {}); } catch (e) { console.error(e); }
      });
    });
  }

  function esc(s) {
    return String(s == null ? "" : s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  }

  function makeApp(desc) {
    var extra = desc.extra || {};

    return {
      id: desc.id,
      title: desc.title,
      glyph: desc.glyph || "R",
      width: extra.width || 520,
      height: extra.height || 460,
      singleton: true,
      showInDock: false,
      showInMenu: true,
      menu: extra.menu || "Hacking Tools",
      external: true,

      render: function (body, win) {
        body.innerHTML =
          '<div class="pad" style="display:flex;flex-direction:column;gap:10px">' +
          '  <div class="muted">Log into another computer on this network to operate the devices linked to it. ' +
          '      Its own account and password are needed, and it has to allow SSH.</div>' +
          '  <div class="r-session" hidden style="padding:10px;border-radius:6px;background:var(--panel)"></div>' +
          '  <div class="r-form" style="display:flex;flex-direction:column;gap:8px">' +
          '    <input class="input r-host" placeholder="Address, for example 192.168.0.5">' +
          '    <input class="input r-user" placeholder="Account">' +
          '    <input class="input r-pass" type="password" placeholder="Password">' +
          '    <div class="toolbar" style="gap:8px">' +
          '      <button class="btn accent r-connect">Connect</button>' +
          '      <button class="btn r-disconnect" hidden>Disconnect</button>' +
          '    </div>' +
          '  </div>' +
          '  <div class="r-status" style="min-height:22px;font-weight:600"></div>' +
          '</div>';

        var elSession = body.querySelector(".r-session");
        var elForm = body.querySelector(".r-form");
        var elStatus = body.querySelector(".r-status");
        var elConnect = body.querySelector(".r-connect");
        var elDisconnect = body.querySelector(".r-disconnect");
        var elHost = body.querySelector(".r-host");
        var elUser = body.querySelector(".r-user");
        var elPass = body.querySelector(".r-pass");

        function setStatus(text, ok) {
          elStatus.textContent = text || "";
          elStatus.style.color = (ok === false) ? "#fa4c58" : (ok === true ? "var(--good)" : "var(--muted)");
        }

        function showSession(host, user) {
          var connected = !!host;

          elSession.hidden = !connected;
          elDisconnect.hidden = !connected;
          // The form stays usable while connected: connecting again just replaces the session
          elForm.style.opacity = connected ? "0.7" : "1";

          if (connected) {
            elSession.innerHTML =
              "<b>Connected to " + esc(host) + "</b>" +
              (user ? '<div class="muted">as ' + esc(user) + "</div>" : "") +
              '<div class="muted">The other Hackerman tools now reach its devices.</div>';
          }
        }

        function onResult(payload) {
          setStatus(payload.message, payload.ok === true);
          showSession(payload.ok === true ? payload.host : "", payload.user);

          // Never keep a password sitting in the window
          elPass.value = "";
        }

        sinks.push(onResult);

        elConnect.addEventListener("click", function () {
          var host = elHost.value.replace(/\s+/g, "");
          var user = elUser.value.replace(/\s+/g, "");

          if (!host || !user) {
            setStatus("An address and an account are needed.", false);
            return;
          }

          setStatus("Connecting to " + host + "...");
          A3.send("rootcw_hack_ssh_connect", { host: host, user: user, pass: elPass.value });
        });

        elDisconnect.addEventListener("click", function () {
          A3.send("rootcw_hack_ssh_disconnect", {});
        });

        elPass.addEventListener("keydown", function (e) {
          if (e.key === "Enter") elConnect.click();
        });

        win.app.onClose = function () {
          var at = sinks.indexOf(onResult);
          if (at >= 0) sinks.splice(at, 1);
        };

        // A session outlives the app being closed, so the current one is asked for on open
        A3.send("rootcw_hack_ssh_status", {});
      }
    };
  }

  window.RootCW_makeHackSshApp = makeApp;
})();
