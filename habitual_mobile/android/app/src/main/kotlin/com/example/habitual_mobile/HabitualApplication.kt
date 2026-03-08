package com.example.habitual_mobile

import io.flutter.app.FlutterApplication
import androidx.multidex.MultiDex
import android.content.Context

class HabitualApplication : FlutterApplication() {
    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        MultiDex.install(this)
    }
}
