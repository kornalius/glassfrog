module.exports = [

  name: 'Statement.Category'
  desc: 'Statement'
  extra:
    display: 'Statement'
    options: 'c'
    icon: 'cic-cmd2'
    color: 'orange'
,

  name: 'Statement'
  desc: 'Statement'
  extra:
    options: 'h!'
    icon: 'cic-cmd2'
    color: 'orange'
,

  name: 'Condition'
  desc: 'Conditional execution'
  extra:
    category: 'Statement.Category'
    options: 'p'
    inherit: 'Statement'
    icon: 'cic-flow-cascade'
    accepts: ['Statement+']
    args:
      'Expression':
        desc: 'Expression to compare'
        component: 'Expression'
,

  name: 'Condition.GreaterThan'
  desc: 'If greater than'
  extra:
    display: 'If greater than'
    inherit: 'Condition'
    icon: 'cic-bigger'
,

  name: 'Condition.GreaterOrEqual'
  desc: 'If greater or equal'
  extra:
    display: 'If greater or equal'
    inherit: 'Condition'
    icon: 'cic-bigger'
,

  name: 'Condition.LesserThan'
  desc: 'If less than'
  extra:
    display: 'If less than'
    inherit: 'Condition'
    icon: 'cic-smaller'
,

  name: 'Condition.LesserOrEqual'
  desc: 'If lesser or equal'
  extra:
    display: 'If lesser or equal'
    inherit: 'Condition'
    icon: 'cic-smaller'
,

  name: 'Condition.Equals'
  desc: 'If equals to'
  extra:
    display: 'If equals to'
    inherit: 'Condition'
    icon: 'cic-equals'
,

  name: 'Condition.NotEqual'
  desc: 'If not equal to'
  extra:
    display: 'If not equal to'
    inherit: 'Condition'
    icon: 'cic-code32'
,

  name: 'Loop'
  desc: 'Loop until condition'
  extra:
    display: 'Loop until'
    options: 'p'
    inherit: 'Statement'
    accepts: ['Statement+']
    icon: 'cic-repeat'
,

  name: 'Loop.Repeat'
  desc: 'Repeat until'
  extra:
    display: 'Repeat until'
    inherit: 'Loop'
    icon: 'cic-repeat'
    args:
      'Expression':
        desc: 'Expression to compare'
        component: 'Expression'
,

  name: 'Loop.ForEach'
  desc: 'For each'
  extra:
    display: 'For each'
    inherit: 'Loop'
    icon: 'cic-repeatone'
    args:
      'Variable':
        desc: 'Variable'
        component: 'Variable'
        nolabel: true
      'in':
        noinput: true
      'Variable':
        desc: 'Variable'
        component: 'Variable'
        nolabel: true

]
