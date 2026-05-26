const card = document.getElementById('card');
const copyBtn = document.getElementById('copyBtn');
const copyBtnText = document.getElementById('copyBtnText');
const shareBtn = document.getElementById('shareBtn');
const toast = document.getElementById('toast');

const CARD_INFO = `우인경 (Inkyeong Woo)
잡기에능한우여사
생산 Unit · SC 제조기술팀
031-8047-2043
ikwoo@amorepacific.com`;

const qrCanvas = document.getElementById('qrCode');
if (qrCanvas && typeof QRCode !== 'undefined') {
  const detailUrl = new URL('detail.html', window.location.href).href;
  QRCode.toCanvas(qrCanvas, detailUrl, {
    width: 112,
    margin: 1,
    color: { dark: '#0a0e1a', light: '#ffffff' },
  });
}

let toastTimer;

function showToast(message) {
  clearTimeout(toastTimer);
  toast.textContent = message;
  toast.classList.add('show');
  toastTimer = setTimeout(() => toast.classList.remove('show'), 2500);
}

copyBtn.addEventListener('click', async () => {
  try {
    await navigator.clipboard.writeText(CARD_INFO);
    copyBtnText.textContent = '복사 완료!';
    showToast('명함 정보가 클립보드에 복사되었습니다');
    setTimeout(() => {
      copyBtnText.textContent = '명함 정보 복사';
    }, 2000);
  } catch {
    showToast('복사에 실패했습니다. 직접 선택해 주세요.');
  }
});

shareBtn.addEventListener('click', async () => {
  const shareData = {
    title: '우인경 — Digital Business Card',
    text: CARD_INFO,
    url: window.location.href,
  };

  if (navigator.share) {
    try {
      await navigator.share(shareData);
    } catch (err) {
      if (err.name !== 'AbortError') showToast('공유에 실패했습니다');
    }
  } else {
    await navigator.clipboard.writeText(window.location.href);
    showToast('링크가 클립보드에 복사되었습니다');
  }
});

card.addEventListener('mousemove', (e) => {
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;

  const rect = card.getBoundingClientRect();
  const x = (e.clientX - rect.left) / rect.width - 0.5;
  const y = (e.clientY - rect.top) / rect.height - 0.5;

  card.style.transform = `perspective(800px) rotateY(${x * 8}deg) rotateX(${-y * 8}deg)`;
});

card.addEventListener('mouseleave', () => {
  card.style.transform = '';
});
