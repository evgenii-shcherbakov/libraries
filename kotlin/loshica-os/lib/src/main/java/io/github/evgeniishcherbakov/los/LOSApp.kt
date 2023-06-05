package io.github.evgeniishcherbakov.los

import android.annotation.SuppressLint
import android.app.Application
import android.content.res.Resources
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import com.google.gson.Gson

open class LOSApp : Application() {

    var online = false

    override fun onCreate() {
        super.onCreate()

        online = isOnline(this)
    }

    companion object {
        var json = Gson()
        const val MONGO_ID = "_id"

        @SuppressLint("MissingPermission")
        fun isOnline(app: Application): Boolean {
            val cm = app.getSystemService(CONNECTIVITY_SERVICE) as ConnectivityManager
            val cp = cm.getNetworkCapabilities(cm.activeNetwork)

            return cp != null && (
                cp.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) ||
                cp.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) ||
                cp.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET)
            )
        }

        fun res(app: Application): Resources = app.resources
    }
}
