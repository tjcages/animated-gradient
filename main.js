import "./style.css"
import fragShader from "./frag.glsl?raw"

import GlslCanvas from "glslCanvas"

const canvas = document.querySelector(".glslCanvas")
canvas.width = window.innerWidth
canvas.height = window.innerHeight

var sandbox = new GlslCanvas(canvas)
sandbox.load(fragShader)

window.addEventListener("resize", () => {
  canvas.width = window.innerWidth
  canvas.height = window.innerHeight
})
