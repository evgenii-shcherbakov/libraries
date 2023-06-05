package io.github.evgeniishcherbakov.los.view

import android.animation.ObjectAnimator
import android.content.Context
import android.view.Gravity
import androidx.appcompat.app.AlertDialog
import com.google.android.material.dialog.MaterialAlertDialogBuilder

class LOSDialogBuilder(context: Context) : MaterialAlertDialogBuilder(context) {

    override fun create(): AlertDialog {
        val dialog: AlertDialog = super.create()
        val window = dialog.window
        val wlp = window!!.attributes

        wlp.gravity = Gravity.BOTTOM
        window.attributes = wlp

        dialog.setOnShowListener {
            val view = window.decorView
            ObjectAnimator
                .ofFloat(view, "translationY", view.height.toFloat(), 0.0f)
                .start()
        }

        return dialog
    }
}
