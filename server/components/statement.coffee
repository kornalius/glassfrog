module.exports = [

  name: 'Statement'
  desc: 'Statement'
  extra:
    options: 'hp'
    icon: 'cmd2'
    color: 'orange'
,

  name: 'Condition'
  desc: 'Conditional execution'
  extra:
    options: 'p'
    inherit: 'Statement'
    icon: 'flow-cascade'
    args:
      'Expression':
        desc: 'Expression to compare'
        component: 'Expression'
,

  name: 'Condition.GreaterThan'
  desc: 'If greater than'
  extra:
    inherit: 'Condition'
    icon: 'bigger'
,

  name: 'Condition.GreaterOrEqual'
  desc: 'If greater or equal'
  extra:
    inherit: 'Condition'
    icon: 'bigger'
,

  name: 'Condition.LesserThan'
  desc: 'If less than'
  extra:
    inherit: 'Condition'
    icon: 'smaller'
,

  name: 'Condition.LesserOrEqual'
  desc: 'If lesser or equal'
  extra:
    inherit: 'Condition'
    icon: 'smaller'
,

  name: 'Condition.Equals'
  desc: 'If equals to'
  extra:
    inherit: 'Condition'
    icon: 'equals'
,

  name: 'Condition.NotEqual'
  desc: 'If not equal to'
  extra:
    inherit: 'Condition'
    icon: 'code32'
,

  name: 'Loop'
  desc: 'Loop until condition'
  extra:
    options: 'p'
    inherit: 'Statement'
    accepts: ['Statement']
    icon: 'repeat'
,

  name: 'Loop.Repeat'
  desc: 'Repeat until'
  extra:
    inherit: 'Loop'
    icon: 'repeat'
    args:
      'Expression':
        desc: 'Expression to compare'
        component: 'Expression'
,

  name: 'Loop.ForEach'
  desc: 'For each'
  extra:
    inherit: 'Loop'
    icon: 'repeatone'
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
