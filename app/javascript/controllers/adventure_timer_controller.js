// 1, ライブラリの読み込み
import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// 2, コントローラーの定義
export default class extends Controller {

  // 3, HTMLから受け取る値を定義
  static targets = ["time"]
  static values = {
    endTime: Number,
    refreshUrl: String
  }

  // 4, 初期設定とライフサイクル
  connect() {
    this.reloaded = false

    this.tick()

    this.timer = setInterval(() => {
      this.tick()
    }, 1000)

    const container = document.getElementById("adventure_events_list")
    this.lastEventId = container ? (container.dataset.lastEventId || 0) : 0

    this.pollTimer = setInterval(() => {
      this.fetchNewEvents()
    }, 5000)
  }

  disconnect() {
    clearInterval(this.timer)
    clearInterval(this.pollTimer)
  }

  // 5, タイマー処理
  tick() {
    const now = Date.now()

    const remainingSeconds = Math.floor(
      (this.endTimeValue - now) / 1000
    )

    if (remainingSeconds <= 0) {
      this.timeTarget.textContent = "00:00"

      clearInterval(this.timer)
      clearInterval(this.pollTimer)

      if (this.reloaded) return

      this.reloaded = true

      setTimeout(() => {
        Turbo.visit(window.location.href)
      }, 300)

      return
    }

    this.timeTarget.textContent =
      this.formatTime(remainingSeconds)
  }

  // 6, イベントを追加する処理
  async fetchNewEvents() {
    if (!this.hasRefreshUrlValue || this.fetching) return

    this.fetching = true

    try {
      const url = `${this.refreshUrlValue}?last_event_id=${this.lastEventId}`
      const response = await fetch(url, {
        headers: {
          "Accept": "text/vnd.turbo-stream.html"
        }
      })

      if (!response.ok) return

      const streamHtml = await response.text()

      if (streamHtml.trim() !== "") {
        Turbo.renderStreamMessage(streamHtml)

        const ids = Array.from(
          document.querySelectorAll(
            "#adventure_events_list > [data-event-id]"
          )
        ).map((element) => Number(element.dataset.eventId))

        if (ids.length > 0) {
          this.lastEventId = Math.max(...ids)
        }
      }
    } finally {
      this.fetching = false
    }
  }

  // 7, 秒数を「分:秒」の形式に変換する処理
  formatTime(totalSeconds) {
    const minutes = Math.floor(totalSeconds / 60)
    const seconds = totalSeconds % 60

    const m = String(minutes).padStart(2, "0")
    const s = String(seconds).padStart(2, "0")

    return `${m}:${s}`
  }
}
