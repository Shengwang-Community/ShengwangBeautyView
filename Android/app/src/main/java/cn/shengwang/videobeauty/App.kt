package cn.shengwang.videobeauty

import android.app.Application

class App: Application() {

    companion object {
        private lateinit var app: Application

        @JvmStatic
        fun instance(): Application {
            return app
        }
    }

    override fun onCreate() {
        super.onCreate()
        app = this
    }
}