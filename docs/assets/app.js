document.addEventListener("DOMContentLoaded", () => {
  const bgSlides = document.querySelectorAll("#global-bg-container .global-bg-slide");
  
  if (bgSlides.length === 0) return;

  let currentSlide = 0;
  const slideInterval = 6000; // Troca o fundo a cada 6 segundos

  function rotateBackground() {
    // Remove a classe ativa do slide atual
    bgSlides[currentSlide].classList.remove("active");

    // Avança para o próximo slide (retorna ao 0 no final)
    currentSlide = (currentSlide + 1) % bgSlides.length;

    // Adiciona a classe ativa ao novo slide
    bgSlides[currentSlide].classList.add("active");
  }

  // Inicia o loop automático
  setInterval(rotateBackground, slideInterval);
});
