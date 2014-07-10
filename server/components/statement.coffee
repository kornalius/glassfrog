module.exports = [

  name: 'Statement'
  desc: 'Statement'
  extra:
    options: 'hp'
    icon: 'code32'
    color: 'orange'
,

  name: 'Expression'
  desc: 'Expression'
  extra:
    inherit: 'Statement'
    icon: 'sum'
    color: 'darkyellow'
,

  name: 'Condition'
  desc: 'Conditional execution'
  extra:
    inherit: 'Statement'
    enum: 'If,Else,Else If,Then,And,Or'
    icon: 'flow-cascade'
,

  name: 'Loop'
  desc: 'Loop until condition'
  extra:
    inherit: 'Statement'
    accepts: ['Statement']
    enum: 'Repeat,ForEach'
    icon: 'repeat'

]
