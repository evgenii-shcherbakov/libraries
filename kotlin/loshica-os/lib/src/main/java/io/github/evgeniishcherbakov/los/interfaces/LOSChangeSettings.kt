package io.github.evgeniishcherbakov.los.interfaces

import android.content.DialogInterface

interface LOSChangeSettings {
    fun changeSettings(dialog: DialogInterface, key: String, value: Int)
}