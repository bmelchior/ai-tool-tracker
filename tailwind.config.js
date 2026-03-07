/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{js,ts,jsx,tsx,mdx}"],
  theme: {
    extend: {
      fontFamily: {
        display: ['"DM Sans"', 'sans-serif'],
        body: ['"IBM Plex Sans"', 'sans-serif'],
        mono: ['"JetBrains Mono"', 'monospace'],
      },
      colors: {
        surface: {
          0: '#0a0a0c',
          1: '#111114',
          2: '#1a1a1f',
          3: '#242429',
          4: '#2e2e35',
        },
        accent: {
          DEFAULT: '#22d3ee',
          dim: '#0e7490',
          bright: '#67e8f9',
        },
        warn: '#f59e0b',
        fav: '#f472b6',
      },
    },
  },
  plugins: [],
};
