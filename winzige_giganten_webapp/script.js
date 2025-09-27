(function(){
  const teaser = document.getElementById('teaserVideo');
  const main = document.getElementById('mainVideo');
  const overlay = document.getElementById('overlay');
  const overlayMsg = document.getElementById('overlayMsg');
  const overlayActions = document.getElementById('overlayActions');
  const retryBtn = document.getElementById('retryBtn');
  const startBtn = document.getElementById('startBtn');

  const TIMEOUT_MS = 15000; // default timeout, matches spec recommendation
  let ready = {teaser:false, main:false};
  let timedOut = false;
  let timeoutHandle = null;

  function markReady(which){
    // Prevent duplicate ready notifications (some browsers fire both
    // 'loadeddata' and 'canplaythrough' for the same media).
    if (ready[which]) {
      console.log('ready (ignored duplicate) -', which);
      return;
    }
    ready[which] = true;
    console.log('ready -', which);
    tryHideOverlay();
  }

  function markError(which, err){
    console.warn('media error', which, err);
    showOverlayError('Failed to load media: ' + which);
  }

  function tryHideOverlay(){
    if((ready.teaser && ready.main) && !timedOut){
      hideOverlay();
    }
  }

  function hideOverlay(){
    overlay.classList.add('hidden');
    // allow keyboard interactions now
    startBtn.style.display = 'none';
    // ensure teaser is visible and playing silently
    teaser.classList.add('visible'); teaser.classList.remove('hidden');
    teaser.play().catch(()=>{});
  }

  function showOverlayError(msg){
    timedOut = true;
    overlayMsg.textContent = msg;
    overlayActions.style.display = 'block';
    overlay.classList.remove('hidden');
    // pause videos to avoid partial playback
    try{ teaser.pause(); main.pause(); }catch(e){}
  }

  function startTimeout(){
    clearTimeout(timeoutHandle);
    timeoutHandle = setTimeout(()=>{
      if(!(ready.teaser && ready.main)){
        showOverlayError('Loading timed out. Check network or retry.');
      }
    }, TIMEOUT_MS);
  }

  // attach events
  teaser.addEventListener('canplaythrough', ()=>markReady('teaser'));
  teaser.addEventListener('loadeddata', ()=>markReady('teaser'));
  teaser.addEventListener('error', (e)=>markError('teaser', e));

  main.addEventListener('canplaythrough', ()=>markReady('main'));
  main.addEventListener('loadeddata', ()=>markReady('main'));
  main.addEventListener('error', (e)=>markError('main', e));

  main.addEventListener('ended', ()=>{
    // when main ends, return to teaser smoothly
    teaser.currentTime = 0;
    teaser.classList.add('visible'); teaser.classList.remove('hidden');
    main.classList.remove('visible'); main.classList.add('hidden');
    teaser.play().catch(()=>{});
  });

  // load kick-off
  function beginLoad(){
    timedOut = false;
    overlayMsg.textContent = 'Loading media, please wait…';
    overlayActions.style.display = 'none';
    overlay.classList.remove('hidden');
    ready.teaser = false; ready.main = false;
    // ensure preload attribute is present
    try{ teaser.load(); main.load(); }catch(e){console.warn(e)}
    startTimeout();
  }

  retryBtn.addEventListener('click', ()=>{
    beginLoad();
  });

  startBtn.addEventListener('click', ()=>{
    if(overlay.classList.contains('hidden')){
      // already ready
      teaser.currentTime = 0; teaser.play().catch(()=>{});
    } else {
      // try to begin load again
      beginLoad();
    }
  });

  // keyboard: Space handling
  window.addEventListener('keydown', (e)=>{
    if(e.code !== 'Space') return;
    // don't react while overlay is active
    if(!overlay.classList.contains('hidden')) return;
    e.preventDefault();
    if(teaser.classList.contains('visible') && !main.classList.contains('visible')){
      // show main
      main.currentTime = 0;
      main.classList.add('visible'); main.classList.remove('hidden');
      teaser.classList.remove('visible'); teaser.classList.add('hidden');
      main.play().catch(()=>{});
    } else if(main.classList.contains('visible')){
      // restart main
      main.currentTime = 0; main.play().catch(()=>{});
    }
  });

  // ensure teaser visible by default but still blocked by overlay until ready
  teaser.classList.add('visible'); teaser.classList.remove('hidden');

  // start preloading automatically on script run
  beginLoad();

  // Register service worker for offline/app-shell behavior (optional)
  if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
      navigator.serviceWorker.register('sw.js').then(reg => {
        console.log('ServiceWorker registered', reg.scope);
      }).catch(err => {
        console.warn('ServiceWorker registration failed', err);
      });
    });
  }
})();
