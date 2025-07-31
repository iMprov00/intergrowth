// public/js/print.js
function prepareForPrint() {
  // Создаем контейнер для печати
  const printContainer = document.createElement('div');
  printContainer.className = 'print-container';
  
  // Получаем данные из страницы
  const gestationalAge = document.querySelector('.display-5').textContent;
  const gender = document.querySelector('.badge').textContent;
  const params = document.querySelectorAll('.col-md-4.mb-3:nth-child(2) .card-body div');
  const assessment = document.querySelector('.physical-dev-assessment').textContent;
  
  // Формируем HTML для печати
  printContainer.innerHTML = `
    <div class="print-header">
      <h2>Оценка роста плода (INTERGROWTH-21st)</h2>
      <h3>${gestationalAge}, ${gender}</h3>
    </div>
    
    <div class="print-data">
      <div class="print-column">
        <div class="print-card">
          <h4>Параметры</h4>
          ${Array.from(params).map(el => el.outerHTML).join('')}
        </div>
      </div>
      
      <div class="print-column">
        <div class="print-card">
          <h4>Оценка физического развития</h4>
          <p style="font-size: 14pt; font-weight: bold;">${assessment}</p>
        </div>
      </div>
    </div>
    
    <div class="print-card">
      <h4>График веса плода (кг)</h4>
      <img id="printWeightImg" class="print-chart-img" alt="График веса">
    </div>
    
    <div class="print-card">
      <h4>График роста плода (см)</h4>
      <img id="printHeightImg" class="print-chart-img" alt="График роста">
    </div>
    
    <div class="print-card">
      <h4>График окружности головы (см)</h4>
      <img id="printHcImg" class="print-chart-img" alt="График окружности головы">
    </div>
    
    <div class="signature">
      <div class="signature-line">Врач _____________ (подпись)</div>
    </div>
  `;
  
  document.body.appendChild(printContainer);
  
  // Конвертируем графики в изображения
  setTimeout(() => {
    // Вес
    const weightCanvas = document.getElementById('weightChart');
    if (weightCanvas) {
      document.getElementById('printWeightImg').src = weightCanvas.toDataURL('image/png');
    }
    
    // Рост
    const heightCanvas = document.getElementById('heightChart');
    if (heightCanvas) {
      document.getElementById('printHeightImg').src = heightCanvas.toDataURL('image/png');
    }
    
    // Окружность головы
    const hcCanvas = document.getElementById('hcChart');
    if (hcCanvas) {
      document.getElementById('printHcImg').src = hcCanvas.toDataURL('image/png');
    }
    
    window.print();
    printContainer.remove();
  }, 500);
}

// Добавляем кнопку печати
function addPrintButton() {
  const btnContainer = document.querySelector('.text-center.mt-4');
  if (!btnContainer) return;
  
  const printBtn = document.createElement('button');
  printBtn.className = 'btn btn-main';
  printBtn.innerHTML = '<i class="bi bi-printer me-2"></i> Печать';
  printBtn.onclick = prepareForPrint;
  
  btnContainer.prepend(printBtn);
}

document.addEventListener('DOMContentLoaded', addPrintButton);