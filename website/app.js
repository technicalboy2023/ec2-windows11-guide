// Theme, search, copy buttons, sidebar, scroll progress, checklist.
// No backend, no tracking, no external requests.
(function(){
  var root=document.documentElement;
  var saved=null; try{saved=localStorage.getItem('ec2guide-theme')}catch(e){}
  if(saved){root.setAttribute('data-theme',saved)}
  var themeBtn=document.getElementById('themeBtn');
  function syncTheme(){themeBtn.textContent=root.getAttribute('data-theme')==='light'?'🌙 Dark':'☀️ Light'}
  syncTheme();
  themeBtn.addEventListener('click',function(){
    var next=root.getAttribute('data-theme')==='light'?'dark':'light';
    root.setAttribute('data-theme',next);
    try{localStorage.setItem('ec2guide-theme',next)}catch(e){}
    syncTheme();
  });
  var menuBtn=document.getElementById('menuBtn'), sidebar=document.getElementById('sidebar');
  menuBtn.addEventListener('click',function(){sidebar.classList.toggle('open')});
  document.querySelectorAll('#toc a').forEach(function(a){
    a.addEventListener('click',function(){sidebar.classList.remove('open')});
  });
  document.querySelectorAll('.copy').forEach(function(btn){
    btn.addEventListener('click',async function(){
      var text=btn.getAttribute('data-copy')||'';
      try{await navigator.clipboard.writeText(text);btn.textContent='Copied ✓';}
      catch(e){
        var ta=document.createElement('textarea');ta.value=text;document.body.appendChild(ta);ta.select();
        try{document.execCommand('copy');btn.textContent='Copied ✓';}catch(e2){btn.textContent='Copy failed';}
        ta.remove();
      }
      setTimeout(function(){btn.textContent='Copy'},1500);
    });
  });
  var search=document.getElementById('search');
  search.addEventListener('input',function(){
    var q=search.value.trim().toLowerCase();
    document.querySelectorAll('main section').forEach(function(s){
      if(!q){s.style.display='';return}
      var hay=(s.getAttribute('data-search')||'')+' '+s.textContent.toLowerCase();
      s.style.display=hay.indexOf(q)>-1?'':'none';
    });
  });
  var boxes=document.querySelectorAll('.step');
  function updateProgress(){
    var done=0; boxes.forEach(function(b){if(b.checked)done++});
    document.getElementById('progressText').textContent=done+' of '+boxes.length+' steps done';
    try{localStorage.setItem('ec2guide-steps',JSON.stringify(Array.from(boxes).map(function(b){return b.checked})))}catch(e){}
  }
  try{
    var prev=JSON.parse(localStorage.getItem('ec2guide-steps')||'[]');
    boxes.forEach(function(b,i){if(prev[i])b.checked=true});
  }catch(e){}
  boxes.forEach(function(b){b.addEventListener('change',updateProgress)});
  updateProgress();
  var bar=document.getElementById('progress');
  window.addEventListener('scroll',function(){
    var h=document.documentElement.scrollHeight-window.innerHeight;
    bar.style.width=(h>0?(window.scrollY/h*100):0)+'%';
  },{passive:true});
})();
