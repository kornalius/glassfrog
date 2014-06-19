// This file was automatically generated from common.soy.
// Please don't edit this file by hand.

if (typeof apps == 'undefined') { var apps = {}; }


apps.messages = function(opt_data, opt_ignored, opt_ijData) {
  return '<div style="display: none"><span id="subtitle">یک محیط برنامه\u200Cنویسی بصری</span><span id="blocklyMessage">بلوکی</span><span id="codeTooltip">دیدن کد جاوااسکریپت ایجادشده.</span><span id="linkTooltip">ذخیره و پیوند به بلوک\u200Cها.</span><span id="runTooltip">اجرای برنامهٔ تعریف\u200Cشده توسط بلوک\u200Cها در فضای کار.</span><span id="runProgram">اجرای برنامه</span><span id="resetProgram">از نو</span><span id="dialogOk">تأیید</span><span id="dialogCancel">لغو</span><span id="catLogic">منطق</span><span id="catLoops">حلقه\u200Cها</span><span id="catMath">ریاضی</span><span id="catText">متن</span><span id="catLists">فهرست\u200Cها</span><span id="catColour">رنگ</span><span id="catVariables">متغییرها</span><span id="catProcedures">توابع</span><span id="httpRequestError">مشکلی با درخواست وجود داشت.</span><span id="linkAlert">اشتراک\u200Cگذاری بلاک\u200Cهایتان با این پیوند:\n\n%1</span><span id="hashError">شرمنده، «%1» با هیچ برنامهٔ ذخیره\u200Cشده\u200Cای تطبیق پیدا نکرد.</span><span id="xmlError">نتوانست پروندهٔ ذخیرهٔ شما بارگیری شود.  احتمالاً با نسخهٔ متفاوتی از بلوکی درست شده\u200Cاست؟</span><span id="listVariable">فهرست</span><span id="textVariable">متن</span></div>';
};


apps.dialog = function(opt_data, opt_ignored, opt_ijData) {
  return '<div id="dialogShadow" class="dialogAnimate"></div><div id="dialogBorder"></div><div id="dialog"></div>';
};


apps.codeDialog = function(opt_data, opt_ignored, opt_ijData) {
  return '<div id="dialogCode" class="dialogHiddenContent"><pre id="containerCode"></pre>' + apps.ok(null, null, opt_ijData) + '</div>';
};


apps.storageDialog = function(opt_data, opt_ignored, opt_ijData) {
  return '<div id="dialogStorage" class="dialogHiddenContent"><div id="containerStorage"></div>' + apps.ok(null, null, opt_ijData) + '</div>';
};


apps.ok = function(opt_data, opt_ignored, opt_ijData) {
  return '<div class="farSide" style="padding: 1ex 3ex 0"><button class="secondary" onclick="BlocklyApps.hideDialog(true)">تأیید</button></div>';
};

;
// This file was automatically generated from template.soy.
// Please don't edit this file by hand.

if (typeof turtlepage == 'undefined') { var turtlepage = {}; }


turtlepage.messages = function(opt_data, opt_ignored, opt_ijData) {
  return apps.messages(null, null, opt_ijData) + '<div style="display: none"><span id="Turtle_moveTooltip">لاک پشت را به مقدار مشخص\u200Cشده جلو یا عقب منتقل می\u200Cکند.</span><span id="Turtle_moveForward">انتقال به جلو تا</span><span id="Turtle_moveBackward">انتقال به پشت تا</span><span id="Turtle_turnTooltip">چرخاندن لاک پشت به چپ یا راست با عدد مشخص\u200Cشدهٔ درجه.</span><span id="Turtle_turnRight">چرخش به راست به مقدار</span><span id="Turtle_turnLeft">چرخش به چپ به مقدار</span><span id="Turtle_widthTooltip">پهنای قلم را تغییر می\u200Cدهد.</span><span id="Turtle_setWidth">تنظیم پهنا به</span><span id="Turtle_colourTooltip">رنگ قلم را تغییر می\u200Cدهد.</span><span id="Turtle_setColour">تنظیم رنگ به</span><span id="Turtle_penTooltip">پالا یا پایین\u200Cبردن قلم، برای شروع یا پایان نقاشی.</span><span id="Turtle_penUp">قلم تا</span><span id="Turtle_penDown">قلم پایین</span><span id="Turtle_turtleVisibilityTooltip">(دایره و فلش) لاک\u200Cکپشت را ظاهر یا پنهان می\u200Cکند.</span><span id="Turtle_hideTurtle">پنهان\u200Cکردن لاک\u200Cپشت</span><span id="Turtle_showTurtle">نمایش لاک\u200Cپشت</span><span id="Turtle_printHelpUrl">https://fa.wikipedia.org/wiki/%DA%86%D8%A7%D9%BE_%28%D8%B5%D9%86%D8%B9%D8%AA%29</span><span id="Turtle_printTooltip">کشیدن متن در جهت لاک\u200Cپشت و موقعیتش.</span><span id="Turtle_print">چاپ</span><span id="Turtle_fontHelpUrl">https://fa.wikipedia.org/wiki/%D9%82%D9%84%D9%85_%28%D8%B1%D8%A7%DB%8C%D8%A7%D9%86%D9%87%29</span><span id="Turtle_fontTooltip">اندازهٔ قلم استفاده شده توسط چاپ بلوک را مشخص می\u200Cکند.</span><span id="Turtle_font">قلم</span><span id="Turtle_fontSize">اندازهٔ قلم</span><span id="Turtle_fontNormal">عادی</span><span id="Turtle_fontBold">پررنگ</span><span id="Turtle_fontItalic">کج</span><span id="Turtle_unloadWarning">رهاکردن این صفحه باعث پاک\u200Cشدن کار شما خواهد شد.</span></div>';
};


turtlepage.start = function(opt_data, opt_ignored, opt_ijData) {
  return turtlepage.messages(null, null, opt_ijData) + '<table width="100%"><tr><td><h1><span id="title"><a href="../index.html?lang=' + soy.$$escapeHtml(opt_ijData.lang) + '">بلوکی</a> : گرافیک لاک\u200Cپشت</span></h1></td><td class="farSide"><select id="languageMenu"></select></td></tr></table><div id="visualization"><canvas id="scratch" width="400" height="400" style="display: none"></canvas><canvas id="display" width="400" height="400"></canvas></div><table style="padding-top: 1em;"><tr><td style="width: 190px; text-align: center; vertical-align: top;"><script type="text/javascript" src="../slider.js"><\/script><svg id="slider" xmlns="http://www.w3.org/2000/svg" xmlns:svg="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="150" height="50"><!-- Slow icon. --><!-- Extra SVG is temporary hack to fix bug #349701 in Chrome 34. --><!-- Harmless for other browsers. --><svg xmlns="http://www.w3.org/2000/svg" version="1.1"><clipPath id="slowClipPath"><rect width=26 height=12 x=5 y=14 /></clipPath><image xlink:href="icons.png" height=42 width=84 x=-21 y=-10 clip-path="url(#slowClipPath)" /></svg><!-- Fast icon. --><!-- Extra SVG is temporary hack to fix bug #349701 in Chrome 34. --><!-- Harmless for other browsers. --><svg xmlns="http://www.w3.org/2000/svg" version="1.1"><clipPath id="fastClipPath"><rect width=26 height=16 x=120 y=10 /></clipPath><image xlink:href="icons.png" height=42 width=84 x=120 y=-11 clip-path="url(#fastClipPath)" /></svg></svg></td><td style="width: 15px;"><img id="spinner" style="visibility: hidden;" src="loading.gif" height=15 width=15></td><td style="width: 190px; text-align: center"><button id="runButton" class="primary" title="اجازه می\u200Cدهد لاک\u200Cپشت هر چه بلوک می\u200Cگوید را انجام دهد."><img src="../../media/1x1.gif" class="run icon21">اجرای برنامه</button><button id="resetButton" class="primary" style="display: none"><img src="../../media/1x1.gif" class="stop icon21"> از نو</button></td></tr></table><div id="toolbarDiv"><button id="codeButton" class="notext" title="دیدن کد جاوااسکریپت ایجادشده."><img src=\'../../media/1x1.gif\' class="code icon21"></button><button id="linkButton" class="notext" title="ذخیره و پیوند به بلوک\u200Cها."><img src=\'../../media/1x1.gif\' class="link icon21"></button><button class="notext" id="captureButton" title="ذخیرهٔ نقاشی."><img src=\'../../media/1x1.gif\' class="img icon21"></button><a id="downloadImageLink" download="drawing.png"></a></div><script type="text/javascript" src="../../blockly_compressed.js"><\/script><script type="text/javascript" src="../../blocks_compressed.js"><\/script><script type="text/javascript" src="../../javascript_compressed.js"><\/script><script type="text/javascript" src="../..//' + soy.$$escapeHtml(opt_ijData.langSrc) + '"><\/script><script type="text/javascript" src="blocks.js"><\/script>' + turtlepage.toolbox(null, null, opt_ijData) + '<div id="blockly"></div>' + apps.dialog(null, null, opt_ijData) + apps.codeDialog(null, null, opt_ijData) + apps.storageDialog(null, null, opt_ijData);
};


turtlepage.toolbox = function(opt_data, opt_ignored, opt_ijData) {
  return '<xml id="toolbox" style="display: none"><category name="لاک\u200Cپشت"><block type="draw_move"><value name="VALUE"><block type="math_number"><field name="NUM">10</field></block></value></block><block type="draw_turn"><value name="VALUE"><block type="math_number"><field name="NUM">90</field></block></value></block><block type="draw_width"><value name="WIDTH"><block type="math_number"><field name="NUM">1</field></block></value></block><block type="draw_pen"></block><block type="turtle_visibility"></block><block type="draw_print"><value name="TEXT"><block type="text"></block></value></block><block type="draw_font"></block></category><category name="رنگ"><block type="draw_colour"><value name="COLOUR"><block type="colour_picker"></block></value></block><block type="colour_picker"></block><block type="colour_random"></block><block type="colour_rgb"></block><block type="colour_blend"></block></category><category name="منطق"><block type="controls_if"></block><block type="logic_compare"></block><block type="logic_operation"></block><block type="logic_negate"></block><block type="logic_boolean"></block><block type="logic_ternary"></block></category><category name="حلقه\u200Cها"><block type="controls_repeat_ext"><value name="TIMES"><block type="math_number"><field name="NUM">10</field></block></value></block><block type="controls_whileUntil"></block><block type="controls_for"><value name="FROM"><block type="math_number"><field name="NUM">1</field></block></value><value name="TO"><block type="math_number"><field name="NUM">10</field></block></value><value name="BY"><block type="math_number"><field name="NUM">1</field></block></value></block><block type="controls_forEach"></block><block type="controls_flow_statements"></block></category><category name="ریاضی"><block type="math_number"></block><block type="math_arithmetic"></block><block type="math_single"></block><block type="math_trig"></block><block type="math_constant"></block><block type="math_number_property"></block><block type="math_change"><value name="DELTA"><block type="math_number"><field name="NUM">1</field></block></value></block><block type="math_round"></block><block type="math_on_list"></block><block type="math_modulo"></block><block type="math_constrain"><value name="LOW"><block type="math_number"><field name="NUM">1</field></block></value><value name="HIGH"><block type="math_number"><field name="NUM">100</field></block></value></block><block type="math_random_int"><value name="FROM"><block type="math_number"><field name="NUM">1</field></block></value><value name="TO"><block type="math_number"><field name="NUM">100</field></block></value></block><block type="math_random_float"></block></category><category name="فهرست\u200Cها"><block type="lists_create_empty"></block><block type="lists_create_with"></block><block type="lists_repeat"><value name="NUM"><block type="math_number"><field name="NUM">5</field></block></value></block><block type="lists_length"></block><block type="lists_isEmpty"></block><block type="lists_indexOf"><value name="VALUE"><block type="variables_get"><field name="VAR">فهرست</field></block></value></block><block type="lists_getIndex"><value name="VALUE"><block type="variables_get"><field name="VAR">فهرست</field></block></value></block><block type="lists_setIndex"><value name="LIST"><block type="variables_get"><field name="VAR">فهرست</field></block></value></block><block type="lists_getSublist"><value name="LIST"><block type="variables_get"><field name="VAR">فهرست</field></block></value></block></category><category name="متغییرها" custom="VARIABLE"></category><category name="توابع" custom="PROCEDURE"></category></xml>';
};
