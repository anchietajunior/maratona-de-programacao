import { Controller } from "@hotwired/stimulus"

// Colors the Python a team is typing: a highlighted layer sits under a transparent
// textarea, so caret and colors share one box.
const TOKENS = /("""[\s\S]*?"""|'''[\s\S]*?'''|"(?:\\.|[^"\\\n])*"|'(?:\\.|[^'\\\n])*')|(#[^\n]*)|\b(False|None|True|and|as|assert|async|await|break|class|continue|def|del|elif|else|except|finally|for|from|global|if|import|in|is|lambda|nonlocal|not|or|pass|raise|return|try|while|with|yield)\b|\b(abs|bool|dict|enumerate|float|input|int|len|list|map|max|min|print|range|reversed|round|set|sorted|str|sum|tuple|zip)\b/g

const CLASSES = [ "tok-string", "tok-comment", "tok-keyword", "tok-builtin" ]

const escapeHtml = (text) => text.replace(/[&<>]/g, (char) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;" })[char])

export default class extends Controller {
  static targets = [ "input", "output" ]

  connect() {
    this.element.setAttribute("data-connected", "")
    this.highlight()
  }

  disconnect() {
    this.element.removeAttribute("data-connected")
  }

  highlight() {
    this.outputTarget.innerHTML = this.#paint(this.inputTarget.value + "\n")
  }

  #paint(code) {
    let painted = ""
    let last = 0

    for (const match of code.matchAll(TOKENS)) {
      const kind = CLASSES[match.slice(1).findIndex((group) => group !== undefined)]

      painted += escapeHtml(code.slice(last, match.index))
      painted += `<span class="${kind}">${escapeHtml(match[0])}</span>`
      last = match.index + match[0].length
    }

    return painted + escapeHtml(code.slice(last))
  }
}
