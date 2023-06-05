package io.github.evgeniishcherbakov.los

import android.content.DialogInterface
import android.os.Bundle
import android.view.Menu
import android.view.View
import io.github.evgenii_shcherbakov.los.R
import io.github.evgenii_shcherbakov.los.databinding.LosActivitySettingsBinding
import io.github.evgenii_shcherbakov.los.databinding.LosDialogAboutBinding
import io.github.evgeniishcherbakov.los.interfaces.LOSChangeSettings
import io.github.evgeniishcherbakov.los.view.LOSAccentDialog
import io.github.evgeniishcherbakov.los.view.LOSDialogBuilder
import io.github.evgeniishcherbakov.los.viewModel.LOSThemeModel

class LOSSettingsActivity : LOSActivity(), View.OnClickListener, LOSChangeSettings {

    private lateinit var b: LosActivitySettingsBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        b = LosActivitySettingsBinding.inflate(layoutInflater)
        setContentView(b.root)

        b.accent.setOnClickListener(this)
        b.dark.setOnClickListener(this)
        b.about.setOnClickListener(this)
    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean = false

    override fun onClick(v: View) {
        when (v) {
            b.accent -> LOSAccentDialog().show(supportFragmentManager, null)
            b.dark -> {
                LOSDialogBuilder(this)
                    .setTitle(resources.getString(R.string.theme_section))
                    .setSingleChoiceItems(
                        resources.getStringArray(R.array.theme_labels),
                        themeModel.settings.getInt(LOSThemeModel.THEME_KEY, 0)
                    ) { dialog, which -> changeSettings(dialog, LOSThemeModel.THEME_KEY, which) }
                    .show()
            }
            else -> {
                LOSDialogBuilder(this)
                    .setTitle(resources.getString(R.string.about_section))
                    .setView(LosDialogAboutBinding.inflate(layoutInflater).root)
                    .show()
            }
        }
    }

    override fun changeSettings(dialog: DialogInterface, key: String, value: Int) {
        val editor = themeModel.settings.edit()
        editor.putInt(key, value)
        editor.apply()
        dialog.dismiss()
        themeModel.change(key, value)
        recreate()
    }
}