package com.example.los

import android.annotation.SuppressLint
import android.os.Bundle
import com.example.los.databinding.ActivityMainBinding
import io.github.evgeniishcherbakov.los.LOSActivity
import io.github.evgeniishcherbakov.los.LOSApp.Companion.isOnline

class MainActivity : LOSActivity() {

    private lateinit var b: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        b = ActivityMainBinding.inflate(layoutInflater)
        setContentView(b.root)
    }

    @SuppressLint("SetTextI18n")
    override fun onResume() {
        super.onResume()
        b.text.text = "online: ${isOnline(application)}"
    }
}