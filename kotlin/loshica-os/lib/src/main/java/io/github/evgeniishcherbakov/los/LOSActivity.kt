package io.github.evgeniishcherbakov.los

import android.content.Intent
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import io.github.evgenii_shcherbakov.los.R
import io.github.evgeniishcherbakov.los.viewModel.LOSThemeModel

open class LOSActivity : AppCompatActivity() {
    // Standart loshica os activity

    val themeModel: LOSThemeModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        // Install theme, when activity created
        themeModel.current.value?.let { setTheme(it) }
        //

        super.onCreate(savedInstanceState)
    }

    override fun onStart() {
        super.onStart()
        // If theme changed -> apply new theme
        themeModel.check(this)
        //
    }

    // Actionbar menu (not necessary, such example to do it)
    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        menuInflater.inflate(R.menu.los_menu_main, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        if (item.itemId == R.id.los_action_settings) {
            // Method to open settings activity
            startActivity(Intent(this.applicationContext, LOSSettingsActivity::class.java))
            //
        }
        return super.onOptionsItemSelected(item)
    }
    //
}