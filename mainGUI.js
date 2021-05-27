import "./style.css"
import fragShader from "./fragGradient.glsl?raw"
import * as dat from "dat.gui"
import GlslCanvas from "glslCanvas"

const canvas = document.querySelector(".glslCanvas")
canvas.width = window.innerWidth
canvas.height = window.innerHeight

var sandbox = new GlslCanvas(canvas)
sandbox.load(fragShader)

const gui = new dat.GUI()
const params = {
  speed: 0.15,
  dimensions: 2,
  scale1: 1.2,
  scale2: 1.0,
  baseColor: 0.25,
  simplexCoefficient: 0.9,
  noiseStrength: 0.02,
  mouseImpact: 0.2,
  bleedOnly: false,
  blackAndWhiteMode: false,
}

const palette = {
  colorA: [0.486 * 255, 0.69 * 255, 0.996 * 255],
  colorB: [0.909 * 255, 0.258 * 255, 0 * 255],
  colorC: [1 * 255, 0.83 * 255, 0.356 * 255],
}

gui.add(params, "speed", 0.05, 0.85).onChange(updateUniforms)
gui.add(params, "dimensions", 2).onChange(updateUniforms)
gui.add(params, "scale1", 0.2, 5).onChange(updateUniforms)
gui.add(params, "scale2", 0.1, 5).onChange(updateUniforms)
gui.add(params, "baseColor", 0.05, 1).onChange(updateUniforms)
gui.add(params, "simplexCoefficient", 0.2, 5).onChange(updateUniforms)
gui.add(params, "noiseStrength", 0.005, 0.1).onChange(updateUniforms)
gui.add(params, "mouseImpact", 0.05, 0.6).onChange(updateUniforms)
gui.add(params, "bleedOnly").onChange(updateUniforms)
gui.add(params, "blackAndWhiteMode").onChange(updateUniforms)
gui.addColor(palette, "colorA").onChange(updateUniforms)
gui.addColor(palette, "colorB").onChange(updateUniforms)
gui.addColor(palette, "colorC").onChange(updateUniforms)

function hexToRgb(hex) {
  var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex)
  return result
    ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16),
      }
    : null
}

function updateUniforms() {
  sandbox.setUniform("u_speed", params.speed)
  sandbox.setUniform("u_dimensions", params.dimensions)
  sandbox.setUniform("u_scale1", params.scale1)
  sandbox.setUniform("u_scale2", params.scale2)
  sandbox.setUniform("u_base_color", params.baseColor)
  sandbox.setUniform("u_simplex_coefficient", params.simplexCoefficient)
  sandbox.setUniform("u_noise_strength", params.noiseStrength)
  sandbox.setUniform("u_mouse_impact", params.mouseImpact)
  // plus sign converts to number
  sandbox.setUniform("u_bleed_only", +params.bleedOnly)

  console.log(typeof palette.colorA, hexToRgb(palette.colorA))

  for (const color in palette) {
    if (typeof palette[color] === "string") {
      const { r, g, b } = hexToRgb(palette[color])
      palette[color] = [r, g, b]
    }
  }

  if (!palette.blackAndWhiteMode) {
    sandbox.setUniform("u_color_a", palette.colorA[0] / 255, palette.colorA[1] / 255, palette.colorA[2] / 255)
    sandbox.setUniform("u_color_b", palette.colorB[0] / 255, palette.colorB[1] / 255, palette.colorB[2] / 255)
    sandbox.setUniform("u_color_c", palette.colorC[0] / 255, palette.colorC[1] / 255, palette.colorC[2] / 255)
  } else {
    sandbox.setUniform("u_color_a", 0, 0, 0)
    sandbox.setUniform("u_color_b", 0.5, 0.5, 0.5)
    sandbox.setUniform("u_color_c", 1, 1, 1)
  }
}

updateUniforms()

window.addEventListener("resize", () => {
  canvas.width = window.innerWidth
  canvas.height = window.innerHeight
})
