package com.example.testapp

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import com.example.testapp.databinding.ActivityMainBinding
import io.github.evgeniishcherbakov.testlib.Main

class MainActivity : AppCompatActivity() {
    private var binding: ActivityMainBinding? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)

        with(binding!!) {
            text.text = "Number: ${Main().init()}"
            setContentView(root)
        }
    }

    override fun onDestroy() {
        binding = null
        super.onDestroy()
    }
}