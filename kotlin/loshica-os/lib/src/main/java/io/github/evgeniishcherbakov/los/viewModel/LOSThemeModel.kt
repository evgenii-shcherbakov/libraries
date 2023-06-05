package io.github.evgeniishcherbakov.los.viewModel

import android.app.Activity
import android.app.Application
import android.content.Context
import android.content.SharedPreferences
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.MutableLiveData
import io.github.evgenii_shcherbakov.los.R

class LOSThemeModel(val app: Application) : AndroidViewModel(app) {

    private val darkThemes = intArrayOf(
        R.style.LOSTheme_BlackOxygen,
        R.style.LOSTheme_BlackViolet,
        R.style.LOSTheme_BlackRed,
        R.style.LOSTheme_BlackBrown,
        R.style.LOSTheme_BlackCyan,
        R.style.LOSTheme_BlackDBlue,
        R.style.LOSTheme_BlackOrange,
        R.style.LOSTheme_BlackPink,
        R.style.LOSTheme_BlackDGreen,
        R.style.LOSTheme_BlackLGreen,
        R.style.LOSTheme_BlackAosp,
        R.style.LOSTheme_BlackWhite
    )
    private val lightThemes = intArrayOf(
        R.style.LOSTheme_LightOxygen,
        R.style.LOSTheme_LightViolet,
        R.style.LOSTheme_LightRed,
        R.style.LOSTheme_LightBrown,
        R.style.LOSTheme_LightCyan,
        R.style.LOSTheme_LightDBlue,
        R.style.LOSTheme_LightOrange,
        R.style.LOSTheme_LightPink,
        R.style.LOSTheme_LightDGreen,
        R.style.LOSTheme_LightLGreen,
        R.style.LOSTheme_LightAosp,
        R.style.LOSTheme_LightBlack
    )

    var settings: SharedPreferences = app.getSharedPreferences(SETTINGS, Context.MODE_PRIVATE)

    private val theme: MutableLiveData<Int> by lazy { MutableLiveData<Int>() }
    val accent: MutableLiveData<Int> by lazy { MutableLiveData<Int>() }
    val current: MutableLiveData<Int> by lazy { MutableLiveData<Int>() }
    val isDark: MutableLiveData<Boolean> by lazy { MutableLiveData<Boolean>() }

    private fun set(): Int {
        isSystemDark = app.resources.configuration.uiMode > 24
        return when (theme.value) {
            0 -> if (isSystemDark) darkThemes[accent.value!!] else lightThemes[accent.value!!]
            1 -> darkThemes[accent.value!!]
            else -> lightThemes[accent.value!!]
        }
    }

    companion object {
        const val SETTINGS = "settings"
        const val ACCENT_KEY = "accent"
        const val THEME_KEY = "theme"
        const val ACCENT_DEFAULT = 2
        const val THEME_DEFAULT = 0

        var isSystemDark = false
    }

    init {
        theme.value = settings.getInt(THEME_KEY, THEME_DEFAULT)
        accent.value = settings.getInt(ACCENT_KEY, ACCENT_DEFAULT)
        current.value = set()
        isDark.value = if (theme.value == 0) isSystemDark else theme.value!! < 2
    }

    fun check(activity: Activity) {
        if (accent.value != settings.getInt(ACCENT_KEY, ACCENT_DEFAULT)) {
            accent.value = settings.getInt(ACCENT_KEY, ACCENT_DEFAULT)
        }

        if (theme.value != settings.getInt(THEME_KEY, THEME_DEFAULT)) {
            theme.value = settings.getInt(THEME_KEY, THEME_DEFAULT)
        }

        val prev = current.value
        current.value = set()

        if (current.value != prev) activity.recreate()
    }

    fun change(key: String, value: Int) {
        when (key) {
            THEME_KEY -> theme.value = value
            ACCENT_KEY -> accent.value = value
        }
        current.value = set()
    }
}
