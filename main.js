import "./style.css"

import GlslCanvas from "glslCanvas"

const canvas = document.querySelector(".glslCanvas")

canvas.width = window.innerWidth
canvas.height = window.innerHeight
var sandbox = new GlslCanvas(canvas)
