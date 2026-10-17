/* =========================================================
   ILLUSTRATIONS (hand-drawn SVG, engraving style)
   ========================================================= */
const P2='var(--paper2)', PP='var(--paper)', K='currentColor';
const sv = (vb, inner) => `<svg viewBox="${vb}" aria-hidden="true"><g fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">${inner}</g></svg>`;
const sky = `<g opacity=".3"><path d="M4 10h30M14 15h40M2 20h22M70 8h24M78 13h16"/></g>`;
const ART = {
cemetery: sv('0 0 160 80', `${sky}<path d="M138 6a11 11 0 1 0 8 19a9 9 0 1 1-8-19z" fill="${K}" opacity=".85"/>
  <path d="M0 64q40-8 80-4t80-2V80H0z" fill="${P2}" stroke="none"/><path d="M0 64q40-8 80-4t80-2"/>
  <path d="M22 64V28M22 42l-10-8M22 37l9-9M22 32l-4-8M31 28l3-4M12 34l-4 2"/>
  <path d="M48 62V44q8-10 16 0v18z" fill="${P2}"/><path d="M52 50h8M52 54h8" opacity=".6"/>
  <path d="M92 63V34M84 42h16" stroke-width="2.4"/>
  <path d="M112 62V50q7-8 14 0v12z" fill="${P2}"/>
  <path d="M60 72h28l-3 6H63z" fill="${K}"/><path d="M92 74q8-8 16 0" fill="${P2}"/>
  <path d="M130 56l-10 18"/><path d="M116 72l4 6 5-3-4-5z" fill="${K}"/>`),
square: sv('0 0 160 80', `${sky}<path d="M8 56V28h44v28M16 28v28M24 28v28M32 28v28M40 28v28M6 28l24-10 24 10" opacity=".5"/>
  <path d="M86 66V12M106 66V12M82 12h28" stroke-width="2.4"/><path d="M87 20h18l-18 9z" fill="${K}"/>
  <path d="M86 48h20M86 54h20"/><circle cx="96" cy="51" r="3"/><path d="M68 66h56v5H68z" fill="${P2}"/>
  <path d="M0 80v-6q4-6 8 0q4-7 9 0q4-6 8 0q5-7 9 0q4-6 8 0q4-7 8 0v6zM118 80v-6q4-6 8 0q4-7 9 0q4-6 8 0q5-7 9 0q4-6 8 0v6z" fill="${K}" stroke="none"/>
  <g fill="${K}" stroke="none"><circle cx="4" cy="70" r="3"/><circle cx="12" cy="69" r="3"/><circle cx="21" cy="70" r="3"/><circle cx="30" cy="69" r="3"/><circle cx="39" cy="70" r="3"/><circle cx="47" cy="69" r="3"/><circle cx="122" cy="70" r="3"/><circle cx="131" cy="69" r="3"/><circle cx="140" cy="70" r="3"/><circle cx="149" cy="69" r="3"/></g>`),
morgue: sv('0 0 160 80', `<path d="M0 66h160"/><path d="M110 50V22a14 14 0 0 1 28 0v28z" fill="${P2}"/><path d="M124 8v42M110 30h28" opacity=".6"/>
  <path d="M60 0v12"/><path d="M55 12h10l-2 9h-6z" fill="${PP}"/><path d="M52 26l-3 3M68 26l3 3M60 27v4" opacity=".5"/>
  <path d="M16 50h92v6H16z" fill="${P2}"/><path d="M24 56v16M100 56v16"/>
  <path d="M18 50q4-12 16-10q8-8 20-2q20-4 40 0q10-2 14 7z" fill="${PP}"/><path d="M40 42q10 3 26 0M76 40q8 3 18 1" opacity=".5"/>
  <path d="M106 48l8 5"/><path d="M113 51l7 4-2 4-7-4z" fill="${PP}"/>`),
slaughter: sv('0 0 160 80', `<path d="M0 72h160"/><path d="M8 72V36l28-16 28 16v36" fill="${P2}"/><path d="M26 72V50h20v22M26 50l20 22M46 50L26 72"/><path d="M30 30h12"/>
  <path d="M82 12h72"/><path d="M96 12v7q0 4 3 4M124 12v7q0 4 3 4M148 12v7q0 4-3 4"/>
  <path d="M99 23q9 4 9 18q0 16-7 24q-6-4-8-14q-2-16 6-28z" fill="${P2}"/><path d="M96 36h8M95 42h10M95 48h10" opacity=".6"/>
  <path d="M127 23q9 4 9 16q0 14-6 20q-6-4-8-12q-1-14 5-24z" fill="${P2}"/>
  <path d="M138 40h14v10h-14z" fill="${K}"/><path d="M145 50v14" stroke-width="3"/>`),
hospital: sv('0 0 160 80', `${sky}<path d="M14 74V32h132v42" fill="${P2}"/><path d="M58 32l22-14 22 14z" fill="${PP}"/><path d="M80 4v12M75 9h10" stroke-width="2.2"/>
  <path d="M72 74V60a8 8 0 0 1 16 0v14" fill="${K}"/>
  <g fill="${K}" opacity=".75" stroke="none"><rect x="22" y="40" width="7" height="10"/><rect x="36" y="40" width="7" height="10"/><rect x="50" y="40" width="7" height="10"/><rect x="103" y="40" width="7" height="10"/><rect x="117" y="40" width="7" height="10"/><rect x="131" y="40" width="7" height="10"/>
  <rect x="22" y="57" width="7" height="10"/><rect x="36" y="57" width="7" height="10"/><rect x="50" y="57" width="7" height="10"/><rect x="103" y="57" width="7" height="10"/><rect x="117" y="57" width="7" height="10"/><rect x="131" y="57" width="7" height="10"/></g>
  <path d="M6 76h148"/>`),
academy: sv('0 0 160 80', `<path d="M138 4l-6 9h6l-6 9" opacity=".7"/><path d="M56 34a24 24 0 0 1 48 0z" fill="${P2}"/><path d="M58 34h44v8H58z" fill="${PP}"/>
  <path d="M77 10h6v-5h-6zM80 5V1M80 10v24M68 15q-4 9-4 19M92 15q4 9 4 19" />
  <path d="M10 72V48h140v24" fill="${PP}"/><path d="M8 48h144M8 44h144"/>
  <path d="M18 50v22M28 50v22M38 50v22M48 50v22M58 50v22M68 50v22M92 50v22M102 50v22M112 50v22M122 50v22M132 50v22M142 50v22"/>
  <path d="M74 72V58a6 6 0 0 1 12 0v14" fill="${K}"/><path d="M2 76h156"/>`),
market: sv('0 0 160 80', `<path d="M0 74h160"/><path d="M8 40h62l-7-12H15z" fill="${P2}"/><path d="M8 40q5 6 10 0q5 6 10 0q5 6 10 0q5 6 11 0q5 6 10 0q5 6 11 0"/>
  <path d="M12 42v32M66 42v32M6 60h66"/><path d="M16 50h12v10H16zM30 52h10v8H30z" fill="${PP}"/><path d="M44 54h18v6H44z" fill="${P2}"/>
  <path d="M88 40h64l-7-12H95z" fill="${P2}"/><path d="M88 40q5 6 11 0q5 6 10 0q5 6 11 0q5 6 10 0q5 6 11 0q5 6 11 0"/>
  <path d="M92 42v32M148 42v32M86 60h68"/>
  <path d="M100 60V48q0-3 3-3h6q3 0 3 3v12z" fill="${PP}"/><path d="M106 45v-8"/><circle cx="106" cy="35" r="2.5" fill="${K}"/>
  <path d="M122 60V48q0-3 3-3h6q3 0 3 3v12z" fill="${PP}"/><path d="M128 45v-8"/><circle cx="128" cy="35" r="2.5" fill="${K}"/>`),
docks: sv('0 0 160 80', `${sky}<path d="M0 74h22M30 77h26M64 74h30M104 77h20M132 74h24" opacity=".5"/><path d="M28 62h80l-10 10H38z" fill="${P2}"/>
  <path d="M66 62V10"/><path d="M68 14q22 18 0 42z" fill="${PP}"/><path d="M64 18l-26 38h26" fill="${PP}"/>
  <path d="M112 62h48"/><path d="M118 48h16v14h-16zM134 52h14v10h-14zM124 36h12v12h-12z" fill="${P2}"/><path d="M118 48l16 14M134 48l-16 14" opacity=".5"/>
  <path d="M10 62V26M6 26h8l-2 8H8z"/>`),
alley: sv('0 0 160 80', `<path d="M0 0L58 24V80H0z" fill="${P2}"/><path d="M160 0L102 24V80h58z" fill="${P2}"/><path d="M58 24h44v56H58z" fill="${K}" opacity=".85"/>
  <path d="M12 20v14h10V24zM12 46v14h10V48zM138 20v14h10V24zM138 46v14h10V48z" fill="${K}" opacity=".6"/>
  <path d="M102 36h10v4"/><path d="M108 40h8l-1 8h-6z" fill="${PP}"/><path d="M112 52v4M104 50l-3 3M120 50l3 3" opacity=".6"/>
  <path d="M73 80V62q0-8 7-10q7 2 7 10v18z" fill="${PP}"/><circle cx="80" cy="47" r="4.5" fill="${PP}"/><path d="M72 44h16M75 44l2-6h6l2 6" fill="${PP}"/>
  <path d="M86 66l8 6" stroke-width="2"/>`),
police: sv('0 0 160 80', `<path d="M18 74V28h124v46" fill="${P2}"/><path d="M14 28h132"/><path d="M80 28V4"/><path d="M80 4h18v10H80z" fill="${PP}"/><path d="M86 4v10M92 4v10" opacity=".6"/>
  <path d="M60 74V52a20 20 0 0 1 40 0v22" fill="${K}"/><path d="M66 74V56M73 74V48M80 74V46M87 74V48M94 74V56" stroke="${P2}"/>
  <path d="M44 46h8l-1 8h-6zM108 46h8l-1 8h-6z" fill="${PP}"/><path d="M56 32h48v9H56z" fill="${PP}"/><path d="M62 36.5h36" opacity=".6"/><path d="M4 76h152"/>`),
church: sv('0 0 160 80', `${sky}<path d="M66 74V22h28v52" fill="${P2}"/><path d="M66 22l14-14 14 14z" fill="${PP}"/><path d="M80 0v9M76 4h8" stroke-width="2.2"/>
  <path d="M30 74V46h36M94 46h36v28" fill="${PP}"/><path d="M28 46l20-10 18 10M94 46l18-10 20 10"/>
  <path d="M73 74V60a7 7 0 0 1 14 0v14" fill="${K}"/><circle cx="80" cy="38" r="6" fill="${PP}"/><path d="M80 32v12M74 38h12" opacity=".6"/>
  <path d="M40 58v10M52 58v10M108 58v10M120 58v10" opacity=".6"/><path d="M24 74h112M18 78h124"/>`),
practice: sv('0 0 160 56', `<path d="M30 44l40-6 40 6v-30l-40-6-40 6z" fill="${PP}"/><path d="M70 8v36"/><path d="M38 18h24M38 24h24M38 30h18M78 18h24M78 24h24" opacity=".6"/>
  <path d="M120 44q-8 0-8-9q0-10 10-10t10 10q0 9-8 9z" fill="${P2}"/><circle cx="118" cy="33" r="2" fill="${K}"/><circle cx="126" cy="33" r="2" fill="${K}"/><path d="M119 41v3M122 41v3M125 41v3"/>`),
blood: sv('0 0 160 56', `<path d="M56 34h48q0 16-24 16t-24-16z" fill="${P2}"/><path d="M60 38q20 6 40 0" stroke="#b83a3a"/><path d="M80 10q8 12 8 18a8 8 0 0 1-16 0q0-6 8-18z" fill="#b83a3a" stroke="#7a2a24"/>
  <path d="M110 14l20-8M126 6l6 2-4 3"/>`),
repair: sv('0 0 160 56', `<path d="M40 40q20-20 40 0t40 0" stroke-dasharray="4 4"/><path d="M50 30l6 6M66 26l4 8M86 34l4-8M102 38l6-6"/><path d="M118 40l26-26"/><path d="M144 14l3-3" stroke-width="2.5"/><path d="M120 38a3 3 0 1 0 4-4"/>`),
charge: sv('0 0 160 56', `<path d="M40 50V30q0-4 4-4h10q4 0 4 4v20z" fill="${PP}"/><path d="M49 26V16"/><circle cx="49" cy="13" r="3" fill="${K}"/>
  <path d="M100 50V30q0-4 4-4h10q4 0 4 4v20z" fill="${PP}"/><path d="M109 26V16"/><circle cx="109" cy="13" r="3" fill="${K}"/>
  <path d="M54 13l10 4-6 2 10 4-6 2 10 4" stroke="#2f5f8f" stroke-width="1.8"/><path d="M70 30l8-4-2 6 8-4" stroke="#2f5f8f"/>`),
};
// Portraits for cadaver and scoundrel cards, built from a seed
function portrait(seed, bg, dark, o){
  o=o||{};
  const r = k => ((seed*9301+49297*k)%233280)/233280;
  const hair = o.hair!=null ? o.hair : Math.floor(r(1)*5), hasHat = o.hat!=null ? !!o.hat : (dark ? r(2)<.7 : r(2)<.25);
  const ink = dark ? 'currentColor' : 'var(--paper-ink)';
  const back = {cemetery:`<path d="M80 70V30q0-18 22-18t22 18v40" fill="${P2}" opacity=".9"/><path d="M96 26h12M102 20v14" opacity=".6"/>`,
    morgue:`<path d="M0 58h120" opacity=".5"/><path d="M10 50h100" opacity=".3"/>`,
    hospital:`<path d="M96 10v14M89 17h14" stroke-width="3" opacity=".55"/>`,
    square:`<path d="M92 70V6M112 70V6M88 6h28" opacity=".5"/>`,
    docks:`<path d="M0 60h30M90 62h30" opacity=".4"/><path d="M100 8v40M102 12q14 14 0 30z" opacity=".4"/>`}[bg]||'';
  const fill = dark ? 'var(--paper-ink)' : PP;
  const hairs = [
    `<path d="M47 26q13-14 26 0q-4-8-13-8t-13 8z" fill="${ink}"/>`,
    `<path d="M46 30q-2-14 14-14t14 14q-2 14 0 22q-4-12-14-12t-14 12q2-8 0-22z" fill="${ink}" opacity=".85"/>`,
    `<path d="M45 28q2-14 15-14t15 14q-6-6-15-6t-15 6z" fill="${ink}"/><path d="M45 26q-4 6 2 10M75 26q4 6-2 10"/>`,
    `<path d="M48 24q12-10 24 0"/>`,
    `<path d="M44 30q0-16 16-16t16 16l-3 8q-1-14-13-14t-13 14z" fill="${ink}" opacity=".7"/>`][hair];
  const hat = hasHat ? ((o.hat ? o.hat==='top' : r(3)<.5) ? `<path d="M44 22h32M50 22V6h20v16" fill="${ink}" stroke="${ink}"/>` : `<path d="M42 22q18-10 36 0q-6-10-18-10t-18 10z" fill="${ink}" stroke="${ink}"/>`) : '';
  const eyes = o.alive ? `<circle cx="55" cy="31" r="1.8" fill="currentColor"/><circle cx="65" cy="31" r="1.8" fill="currentColor"/><path d="M52 27q3-2 6 0M62 27q3-2 6 0"/>` : dark ? `<path d="M54 32h4M62 32h4" stroke="${PP}" stroke-width="2"/>` : `<path d="M53 32q2 2 5 0M62 32q2 2 5 0"/>`;
  return `<svg viewBox="0 0 120 70" aria-hidden="true"><g fill="none" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round" style="color:var(--paper-ink)">
    ${back}<path d="M24 70q4-18 22-22h28q18 4 22 22z" fill="${fill}"/><path d="M52 48v-6h16v6" fill="${fill}"/>
    <ellipse cx="60" cy="32" rx="14" ry="17" fill="${fill}"/>${hairs}${hat}${eyes}<path d="M57 42q3 1 6 0" ${dark?`stroke="${PP}"`:''}/>
    ${dark?'':`<path d="M50 56q10 6 20 0" opacity=".5"/>`}</g></svg>`;
}
const ICONART = {
  book: sv('0 0 120 50', `<path d="M30 40l30-5 30 5V12l-30-5-30 5z" fill="${PP}"/><path d="M60 7v33"/><path d="M36 16h18M36 21h18M36 26h12M66 16h18M66 21h18" opacity=".6"/>`),
  glove: sv('0 0 120 50', `<path d="M48 44V24l-6-8q-2-4 2-5l8 8V8q0-3 3-3t3 3v10V5q0-3 3-3t3 3v13V7q0-3 3-3t3 3v12V11q0-3 3-3t3 3v22q0 11-12 11z" fill="${P2}"/>`),
  jar: sv('0 0 120 50', `<path d="M48 46V24q0-4 4-4h16q4 0 4 4v22z" fill="${PP}"/><path d="M60 20V9"/><circle cx="60" cy="7" r="3" fill="${K}"/><path d="M66 6l10-3-6 6 10-2" stroke="#2f5f8f"/>`),
  coin: sv('0 0 120 50', `<circle cx="52" cy="26" r="14" fill="${P2}"/><circle cx="52" cy="26" r="10"/><circle cx="72" cy="30" r="12" fill="${PP}"/><path d="M68 30h8M72 26v8"/>`),
  flask: sv('0 0 120 50', `<path d="M54 6h12M56 6v14l-12 22q-2 4 3 4h26q5 0 3-4L64 20V6" fill="${PP}"/><path d="M48 36h24" opacity=".6"/><circle cx="58" cy="40" r="2" fill="${K}"/><circle cx="66" cy="38" r="1.5" fill="${K}"/>`),
  candle: sv('0 0 120 50', `<path d="M54 46V20h12v26z" fill="${PP}"/><path d="M60 20v-4"/><path d="M60 16q-5-6 0-13q5 7 0 13z" fill="#e3b04b"/><path d="M44 46h32"/><path d="M48 12l-4-3M72 12l4-3M60 1V0" opacity=".5"/>`),
};
const DIEICON = {
  alive:`<svg viewBox="0 0 24 24"><path d="M2 12q10-10 20 0q-10 10-20 0z" fill="none" stroke="#fff" stroke-width="1.8"/><circle cx="12" cy="12" r="3.5" fill="#fff"/></svg>`,
  damage:`<svg viewBox="0 0 24 24"><path d="M14 2L6 13h5l-2 9 9-12h-5z" fill="#ffd36a"/></svg>`,
  heart:`<svg viewBox="0 0 24 24"><path d="M12 21q-9-6-9-12a5 5 0 0 1 9-3a5 5 0 0 1 9 3q0 6-9 12z" fill="#d6675f"/><path d="M12 6l-2 5 3 2-2 5" stroke="#4a4550" stroke-width="1.6" fill="none"/></svg>`,
  blank:''
};

