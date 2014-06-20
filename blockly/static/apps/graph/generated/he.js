// This file was automatically generated from common.soy.
// Please don't edit this file by hand.

if (typeof apps == 'undefined') { var apps = {}; }


apps.messages = function(opt_data, opt_ignored, opt_ijData) {
  return '<div style="display: none"><span id="subtitle">סביבת תיכנות חזותי</span><span id="blocklyMessage">בלוקלי</span><span id="codeTooltip">הצגת קוד ה־Javascript שנוצר.</span><span id="linkTooltip">שמירה וקישור לקטעי קוד.</span><span id="runTooltip">הרצת התכנית שהוגדרה על ידי קטעי הקוד שבמרחב העבודה.</span><span id="runProgram">הרץ תכנית</span><span id="resetProgram">איפוס</span><span id="dialogOk">אישור</span><span id="dialogCancel">ביטול</span><span id="catLogic">לוגיקה</span><span id="catLoops">לולאות</span><span id="catMath">מתמטיקה</span><span id="catText">טקסט</span><span id="catLists">רשימות</span><span id="catColour">צבע</span><span id="catVariables">משתנים</span><span id="catProcedures">פונקציות</span><span id="httpRequestError">הבקשה נכשלה.</span><span id="linkAlert">ניתן לשתף את קטעי הקוד שלך באמצעות קישור זה:\n\n%1</span><span id="hashError">לצערנו, \'%1\' איננו מתאים לאף אחת מהתוכניות השמורות</span><span id="xmlError">נסיון הטעינה של הקובץ השמור שלך נכשל. האם ייתכן שהוא נוצר בגרסא שונה של בלוקלי?</span><span id="listVariable">רשימה</span><span id="textVariable">טקסט</span></div>';
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
  return '<div class="farSide" style="padding: 1ex 3ex 0"><button class="secondary" onclick="BlocklyApps.hideDialog(true)">אישור</button></div>';
};

;
// This file was automatically generated from template.soy.
// Please don't edit this file by hand.

if (typeof graphpage == 'undefined') { var graphpage = {}; }


graphpage.messages = function(opt_data, opt_ignored, opt_ijData) {
  return apps.messages(null, null, opt_ijData);
};


graphpage.start = function(opt_data, opt_ignored, opt_ijData) {
  return graphpage.messages(null, null, opt_ijData) + '<table width="100%"><tr><td><h1><span id="title"><a href="../index.html?lang=' + soy.$$escapeHtml(opt_ijData.lang) + '">בלוקלי</a> : מחשבון גרפים</span></h1></td><td class="farSide"><select id="languageMenu"></select>&nbsp; &nbsp;<button id="linkButton" class="notext" title="שמירה וקישור לקטעי קוד."><img src=\'link.png\' height=21 width=21></button></div></td></tr></table><div id="visualization"></div><div id="funcText"><img id="y1" src="../../media/1x1.gif">...</div><script type="text/javascript" src="../../blockly_compressed.js"><\/script><script type="text/javascript" src="../../blocks_compressed.js"><\/script><script type="text/javascript" src="../../javascript_compressed.js"><\/script><script type="text/javascript" src="../..//' + soy.$$escapeHtml(opt_ijData.langSrc) + '"><\/script><script type="text/javascript" src="blocks.js"><\/script>' + graphpage.toolbox(null, null, opt_ijData) + '<div id="blockly"></div>' + apps.dialog(null, null, opt_ijData) + apps.storageDialog(null, null, opt_ijData);
};


graphpage.toolbox = function(opt_data, opt_ignored, opt_ijData) {
  return '<xml id="toolbox" style="display: none"><category name="מתמטיקה"><block type="math_number"></block><block type="math_arithmetic"></block><block type="math_single"></block><block type="math_trig"></block><block type="math_constant"></block><block type="math_number_property"></block><block type="math_round"></block><block type="math_modulo"></block><block type="math_constrain"><value name="LOW"><block type="math_number"><field name="NUM">1</field></block></value><value name="HIGH"><block type="math_number"><field name="NUM">100</field></block></value></block><block type="math_random_int"><value name="FROM"><block type="math_number"><field name="NUM">1</field></block></value><value name="TO"><block type="math_number"><field name="NUM">100</field></block></value></block><block type="math_random_float"></block></category><category name="משתנים"><block type="graph_get_x"></block></category><category name="לוגיקה"><block type="logic_compare"></block><block type="logic_operation"></block><block type="logic_negate"></block><block type="logic_boolean"></block><block type="logic_ternary"></block></category></xml>';
};