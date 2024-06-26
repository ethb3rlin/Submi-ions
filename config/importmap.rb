# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

pin "eip55", to: "https://ga.jspm.io/npm:eip55@2.1.1/index.js"
pin "#lib/internal/streams/from.js", to: "https://ga.jspm.io/npm:readable-stream@3.6.2/lib/internal/streams/from-browser.js"
pin "#lib/internal/streams/stream.js", to: "https://ga.jspm.io/npm:readable-stream@3.6.2/lib/internal/streams/stream-browser.js"
pin "buffer", to: "https://ga.jspm.io/npm:@jspm/core@2.0.1/nodelibs/browser/buffer.js"
pin "events", to: "https://ga.jspm.io/npm:@jspm/core@2.0.1/nodelibs/browser/events.js"
pin "inherits", to: "https://ga.jspm.io/npm:inherits@2.0.4/inherits_browser.js"
pin "keccak", to: "https://ga.jspm.io/npm:keccak@3.0.4/js.js"
pin "process", to: "https://ga.jspm.io/npm:@jspm/core@2.0.1/nodelibs/browser/process.js"
pin "readable-stream", to: "https://ga.jspm.io/npm:readable-stream@3.6.2/readable-browser.js"
pin "safe-buffer", to: "https://ga.jspm.io/npm:safe-buffer@5.2.1/index.js"
pin "string_decoder", to: "https://ga.jspm.io/npm:string_decoder@1.3.0/lib/string_decoder.js"
pin "util", to: "https://ga.jspm.io/npm:@jspm/core@2.0.1/nodelibs/browser/util.js"
pin "util-deprecate", to: "https://ga.jspm.io/npm:util-deprecate@1.0.2/browser.js"
pin "list.js", to: "https://ga.jspm.io/npm:list.js@2.3.1/src/index.js"
pin "string-natural-compare", to: "https://ga.jspm.io/npm:string-natural-compare@2.0.3/natural-compare.js"
pin "local-time" # @3.0.2
