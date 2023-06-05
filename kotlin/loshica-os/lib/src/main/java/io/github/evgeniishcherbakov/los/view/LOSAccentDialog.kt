package io.github.evgeniishcherbakov.los.view

import android.annotation.SuppressLint
import android.app.Dialog
import android.os.Bundle
import android.view.Gravity
import android.view.View
import android.widget.CheckedTextView
import android.widget.RadioGroup
import androidx.fragment.app.DialogFragment
import androidx.fragment.app.activityViewModels
import androidx.fragment.app.viewModels
import io.github.evgenii_shcherbakov.los.R
import io.github.evgenii_shcherbakov.los.databinding.LosDialogAccentBinding
import io.github.evgeniishcherbakov.los.interfaces.LOSDialogChangeSettings
import io.github.evgeniishcherbakov.los.viewModel.LOSThemeModel

class LOSAccentDialog : DialogFragment(), View.OnClickListener, LOSDialogChangeSettings {

    private var _b: LosDialogAccentBinding? = null
    private val b get() = _b!!

    private val coloredBgs = intArrayOf(
        R.drawable.los_colored_btn_bg_oxygen,
        R.drawable.los_colored_btn_bg_violet,
        R.drawable.los_colored_btn_bg_red,
        R.drawable.los_colored_btn_bg_brown,
        R.drawable.los_colored_btn_bg_cyan,
        R.drawable.los_colored_btn_bg_dblue,
        R.drawable.los_colored_btn_bg_orange,
        R.drawable.los_colored_btn_bg_pink,
        R.drawable.los_colored_btn_bg_dgreen,
        R.drawable.los_colored_btn_bg_lgreen,
        R.drawable.los_colored_btn_bg_aosp,
        R.drawable.los_colored_btn_bg_black,
        R.drawable.los_colored_btn_bg_white
    )

    private lateinit var lp: RadioGroup.LayoutParams

    private val themeModel: LOSThemeModel by viewModels()
    private val parentModel: LOSThemeModel by activityViewModels()

    @SuppressLint("ResourceType")
    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val builder = LOSDialogBuilder(requireActivity())

        _b = LosDialogAccentBinding.inflate(requireActivity().layoutInflater)
        lp = RadioGroup.LayoutParams(120, 120)

        for (i in 0 until coloredBgs.size - 1) {
            val button = CheckedTextView(this.context)

            button.setText(R.string.colored_btn_text)
            button.id = i
            button.gravity = Gravity.CENTER
            button.textAlignment = View.TEXT_ALIGNMENT_CENTER
            button.setTextAppearance(R.style.LOSColoredBthStyle)
            button.setBackgroundResource(
                if (i == coloredBgs.size - 2 && themeModel.isDark.value!!)
                    coloredBgs[i + 1] else coloredBgs[i]
            )
            button.setOnClickListener(this)

            if (themeModel.accent.value == i) button.isChecked = true
            if (i - 6 < 0) b.row0.addView(button, lp) else b.row1.addView(button, lp)
        }

        return builder
            .setView(b.root)
            .setTitle(requireActivity().resources.getText(R.string.accent_section))
            .create()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _b = null
    }

    override fun onClick(v: View) {
        changeSettings(LOSThemeModel.ACCENT_KEY, v.id)
    }

    override fun changeSettings(key: String, value: Int) {
        val editor = themeModel.settings.edit()
        editor.putInt(key, value)
        editor.apply()
        this.dismiss()
        themeModel.change(key, value)
        parentModel.change(key, value)
        requireActivity().recreate()
    }
}