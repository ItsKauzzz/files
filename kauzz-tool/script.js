const state = {
  image: null,
  originalImageData: null,
  palette: [],
  paletteGroups: [],
  importedPalette: [],
  mappings: []
};

const elements = {
  imageInput: document.getElementById('imageInput'),
  paletteSize: document.getElementById('paletteSize'),
  paletteSizeValue: document.getElementById('paletteSizeValue'),
  extractPaletteButton: document.getElementById('extractPaletteButton'),
  exportPaletteButton: document.getElementById('exportPaletteButton'),
  paletteImportInput: document.getElementById('paletteImportInput'),
  paletteImportStatus: document.getElementById('paletteImportStatus'),
  applyReplacementButton: document.getElementById('applyReplacementButton'),
  downloadButton: document.getElementById('downloadButton'),
  previewCanvas: document.getElementById('previewCanvas'),
  imageMeta: document.getElementById('imageMeta'),
  paletteSummary: document.getElementById('paletteSummary'),
  paletteGroups: document.getElementById('paletteGroups'),
  mappingList: document.getElementById('mappingList'),
  mappingSummary: document.getElementById('mappingSummary')
};

const canvasContext = elements.previewCanvas.getContext('2d', { willReadFrequently: true });

elements.paletteSize.addEventListener('input', () => {
  elements.paletteSizeValue.value = elements.paletteSize.value;
});

elements.imageInput.addEventListener('change', async (event) => {
  const [file] = event.target.files || [];
  if (!file) return;
  const image = await loadImageFromFile(file);
  drawImageToCanvas(image);
  state.image = image;
  state.originalImageData = canvasContext.getImageData(0, 0, elements.previewCanvas.width, elements.previewCanvas.height);
  state.palette = [];
  state.paletteGroups = [];
  state.mappings = [];
  elements.imageMeta.textContent = `${image.width} × ${image.height}px`;
  elements.extractPaletteButton.disabled = false;
  elements.downloadButton.disabled = false;
  renderPalette();
  renderMappings();
});

elements.extractPaletteButton.addEventListener('click', () => {
  if (!state.originalImageData) return;
  const maxColors = Number(elements.paletteSize.value);
  state.palette = extractPalette(state.originalImageData, maxColors);
  state.paletteGroups = groupAndSortPalette(state.palette);
  autoBuildMappings();
  renderPalette();
  renderMappings();
  elements.exportPaletteButton.disabled = state.palette.length === 0;
});

elements.exportPaletteButton.addEventListener('click', () => {
  if (!state.palette.length) return;
  const payload = {
    exportedAt: new Date().toISOString(),
    colors: state.palette.map((color) => color.hex)
  };
  const blob = new Blob([JSON.stringify(payload, null, 2)], { type: 'application/json' });
  downloadBlob(blob, 'kauzz-palette.json');
});

elements.paletteImportInput.addEventListener('change', async (event) => {
  const [file] = event.target.files || [];
  if (!file) return;
  const text = await file.text();
  const parsed = JSON.parse(text);
  const colors = Array.isArray(parsed) ? parsed : parsed.colors;
  state.importedPalette = (colors || []).map(normalizeHex).filter(Boolean).map(createColorRecord);
  elements.paletteImportStatus.textContent = state.importedPalette.length
    ? `${state.importedPalette.length} cores importadas.`
    : 'Arquivo sem cores válidas.';
  autoBuildMappings();
  renderMappings();
});

elements.applyReplacementButton.addEventListener('click', () => {
  if (!state.originalImageData || !state.mappings.length) return;
  const mappingTable = new Map(state.mappings.map((mapping) => [mapping.source.hex, mapping.target.hex]));
  const newImageData = new ImageData(
    new Uint8ClampedArray(state.originalImageData.data),
    state.originalImageData.width,
    state.originalImageData.height
  );

  for (let i = 0; i < newImageData.data.length; i += 4) {
    const alpha = newImageData.data[i + 3];
    if (alpha === 0) continue;
    const nearestSource = findNearestPaletteColor({
      r: newImageData.data[i],
      g: newImageData.data[i + 1],
      b: newImageData.data[i + 2]
    }, state.palette);
    if (!nearestSource) continue;
    const replacementHex = mappingTable.get(nearestSource.hex);
    if (!replacementHex) continue;
    const { r, g, b } = hexToRgb(replacementHex);
    newImageData.data[i] = r;
    newImageData.data[i + 1] = g;
    newImageData.data[i + 2] = b;
  }

  canvasContext.putImageData(newImageData, 0, 0);
});

elements.downloadButton.addEventListener('click', () => {
  elements.previewCanvas.toBlob((blob) => {
    if (!blob) return;
    downloadBlob(blob, 'kauzz-recolored.png');
  });
});

function loadImageFromFile(file) {
  return new Promise((resolve, reject) => {
    const image = new Image();
    image.onload = () => resolve(image);
    image.onerror = reject;
    image.src = URL.createObjectURL(file);
  });
}

function drawImageToCanvas(image) {
  elements.previewCanvas.width = image.width;
  elements.previewCanvas.height = image.height;
  canvasContext.clearRect(0, 0, image.width, image.height);
  canvasContext.drawImage(image, 0, 0);
}

function extractPalette(imageData, maxColors) {
  const buckets = new Map();
  const step = Math.max(1, Math.floor(Math.sqrt((imageData.width * imageData.height) / 20000)));

  for (let y = 0; y < imageData.height; y += step) {
    for (let x = 0; x < imageData.width; x += step) {
      const index = (y * imageData.width + x) * 4;
      const a = imageData.data[index + 3];
      if (a < 16) continue;
      const r = quantizeChannel(imageData.data[index]);
      const g = quantizeChannel(imageData.data[index + 1]);
      const b = quantizeChannel(imageData.data[index + 2]);
      const key = `${r}-${g}-${b}`;
      buckets.set(key, (buckets.get(key) || 0) + 1);
    }
  }

  return [...buckets.entries()]
    .sort((a, b) => b[1] - a[1])
    .slice(0, maxColors)
    .map(([key, count]) => {
      const [r, g, b] = key.split('-').map(Number);
      return createColorRecord(normalizeHex(rgbToHex(r, g, b)), count);
    });
}

function groupAndSortPalette(colors) {
  const hueThreshold = 26;
  const sorted = [...colors].sort((a, b) => a.hsl.h - b.hsl.h);
  const groups = [];

  for (const color of sorted) {
    const currentGroup = groups[groups.length - 1];
    if (!currentGroup || hueDistance(currentGroup.hue, color.hsl.h) > hueThreshold) {
      groups.push({ hue: color.hsl.h, colors: [color] });
    } else {
      currentGroup.colors.push(color);
      currentGroup.hue = average(currentGroup.colors.map((item) => item.hsl.h));
    }
  }

  return groups.map((group, index) => ({
    id: index,
    hue: group.hue,
    colors: group.colors.sort((a, b) => a.hsl.l - b.hsl.l)
  }));
}

function autoBuildMappings() {
  if (!state.palette.length || !state.importedPalette.length) {
    state.mappings = [];
    elements.applyReplacementButton.disabled = true;
    return;
  }

  const sortedSource = flattenPaletteGroups(groupAndSortPalette(state.palette));
  const sortedTarget = flattenPaletteGroups(groupAndSortPalette(state.importedPalette));
  state.mappings = sortedSource.map((source, index) => ({
    source,
    target: sortedTarget[index % sortedTarget.length]
  }));
  elements.applyReplacementButton.disabled = false;
}

function flattenPaletteGroups(groups) {
  return groups.flatMap((group) => group.colors);
}

function renderPalette() {
  if (!state.paletteGroups.length) {
    elements.paletteGroups.className = 'palette-groups empty-state';
    elements.paletteGroups.textContent = 'Carregue uma imagem para visualizar a paleta.';
    elements.paletteSummary.textContent = '0 cores';
    return;
  }

  elements.paletteGroups.className = 'palette-groups';
  elements.paletteSummary.textContent = `${state.palette.length} cores em ${state.paletteGroups.length} grupos`;
  elements.paletteGroups.innerHTML = state.paletteGroups.map((group) => `
    <section class="palette-group">
      <div class="group-title">
        <strong>Grupo ${group.id + 1}</strong>
        <span class="meta">Hue médio ${Math.round(group.hue)}°</span>
      </div>
      <div class="swatch-row">
        ${group.colors.map((color) => `
          <article class="swatch-card">
            <div class="swatch" style="background:${color.hex}"></div>
            <div>
              <code>${color.hex}</code>
              <div class="meta">L ${Math.round(color.hsl.l)} · ${color.count || 0} px</div>
            </div>
          </article>
        `).join('')}
      </div>
    </section>
  `).join('');
}

function renderMappings() {
  if (!state.mappings.length) {
    elements.mappingList.className = 'mapping-list empty-state';
    elements.mappingList.textContent = 'Importe uma imagem e uma paleta para habilitar as substituições.';
    elements.mappingSummary.textContent = 'Nenhum mapeamento disponível';
    return;
  }

  elements.mappingList.className = 'mapping-list';
  elements.mappingSummary.textContent = `${state.mappings.length} substituições configuradas`;
  elements.mappingList.innerHTML = state.mappings.map((mapping, index) => `
    <article class="mapping-item">
      <div class="mapping-row">
        <div class="color-chip" style="background:${mapping.source.hex}"></div>
        <div>
          <strong>Origem</strong>
          <div><code>${mapping.source.hex}</code></div>
        </div>
      </div>
      <div class="meta">→</div>
      <label class="select-wrapper">
        <span>Destino</span>
        <select data-index="${index}">
          ${state.importedPalette.map((color) => `
            <option value="${color.hex}" ${color.hex === mapping.target.hex ? 'selected' : ''}>${color.hex}</option>
          `).join('')}
        </select>
      </label>
    </article>
  `).join('');

  elements.mappingList.querySelectorAll('select').forEach((select) => {
    select.addEventListener('change', (event) => {
      const idx = Number(event.target.dataset.index);
      const next = state.importedPalette.find((color) => color.hex === event.target.value);
      if (next) state.mappings[idx].target = next;
    });
  });
}

function createColorRecord(hex, count = 0) {
  const { r, g, b } = hexToRgb(hex);
  return { hex, count, hsl: rgbToHsl(r, g, b) };
}

function normalizeHex(value) {
  if (typeof value !== 'string') return null;
  const hex = value.trim().replace(/^#?([0-9a-f]{6})$/i, '#$1').toUpperCase();
  return /^#[0-9A-F]{6}$/.test(hex) ? hex : null;
}

function quantizeChannel(value) {
  return Math.min(255, Math.round(value / 16) * 16);
}

function rgbToHex(r, g, b) {
  return `#${[r, g, b].map((value) => value.toString(16).padStart(2, '0')).join('')}`.toUpperCase();
}

function hexToRgb(hex) {
  const normalized = normalizeHex(hex);
  return {
    r: parseInt(normalized.slice(1, 3), 16),
    g: parseInt(normalized.slice(3, 5), 16),
    b: parseInt(normalized.slice(5, 7), 16)
  };
}

function rgbToHsl(r, g, b) {
  const red = r / 255;
  const green = g / 255;
  const blue = b / 255;
  const max = Math.max(red, green, blue);
  const min = Math.min(red, green, blue);
  const l = (max + min) / 2;
  const d = max - min;

  if (d === 0) return { h: 0, s: 0, l: l * 100 };

  const s = d / (1 - Math.abs(2 * l - 1));
  let h;

  switch (max) {
    case red:
      h = 60 * (((green - blue) / d) % 6);
      break;
    case green:
      h = 60 * ((blue - red) / d + 2);
      break;
    default:
      h = 60 * ((red - green) / d + 4);
      break;
  }

  return { h: (h + 360) % 360, s: s * 100, l: l * 100 };
}

function hueDistance(a, b) {
  const diff = Math.abs(a - b);
  return Math.min(diff, 360 - diff);
}

function average(numbers) {
  return numbers.reduce((sum, value) => sum + value, 0) / numbers.length;
}

function findNearestPaletteColor(pixel, palette) {
  if (!palette.length) return null;
  let winner = palette[0];
  let bestDistance = Number.POSITIVE_INFINITY;

  for (const color of palette) {
    const rgb = hexToRgb(color.hex);
    const distance = Math.sqrt(
      (pixel.r - rgb.r) ** 2 +
      (pixel.g - rgb.g) ** 2 +
      (pixel.b - rgb.b) ** 2
    );

    if (distance < bestDistance) {
      bestDistance = distance;
      winner = color;
    }
  }

  return winner;
}

function downloadBlob(blob, filename) {
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement('a');
  anchor.href = url;
  anchor.download = filename;
  anchor.click();
  setTimeout(() => URL.revokeObjectURL(url), 0);
}
