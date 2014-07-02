'use strict'

angular.module('dragdrop.service', ['app', 'app.globals', 'editor', 'editor.node'])

.directive('draggable', [

  () ->
    restrict: 'A'

    link: (scope, element, attrs) ->
      triggerZone = 20
      scrollSpeed = 4
      #      insertZone = 8
      scope.isComponent = false

      $(element).draggable(
        revert: true
        revertDuration: 100
        helper: "clone"
        addClasses: true
        appendTo: "body"
        scroll: false
        tolerance: 'pointer'
        opacity: 0.90
        zIndex: 100000
        refreshPositions: true

        start: (event, ui) ->
          $(ui.helper).addClass('drag-tilt')
          $(ui.helper).addClass('drag-shadow')
          $(this).hide()

        drag: (event, ui) ->
          $(".nodes").each(() ->
            $this = $(this)
            cOffset = $this.offset()
            bottomPos = cOffset.top + $this.height()
            clearInterval($this.data('timerScroll'))
            $this.data('timerScroll', false)
            if event.pageX >= cOffset.left and event.pageX <= cOffset.left + $this.width()
              if event.pageY >= bottomPos - triggerZone and event.pageY <= bottomPos
                moveUp = () ->
                  $this.scrollTop($this.scrollTop() + scrollSpeed);
                $this.data('timerScroll', setInterval(moveUp, 10));
                moveUp()

              if event.pageY >= cOffset.top and event.pageY <= cOffset.top + triggerZone
                moveDown = () ->
                  $this.scrollTop($this.scrollTop() - scrollSpeed)
                $this.data('timerScroll', setInterval(moveDown, 10))
                moveDown()
          )

        stop: (event, ui) ->
          $(".nodes").each(() ->
            clearInterval($(this).data('timerScroll'))
            $(this).data('timerScroll', false)
          )
          $(ui.helper).removeClass('drag-tilt')
          $(ui.helper).removeClass('drag-shadow')
          $(".dropzone").removeClass('dropzone-active')
          $(".dropzone").removeClass('dropzone-hover')
          $(".node").removeClass('drag-hover')
          $(".node").removeClass('drag-invalid')
          $(this).show()
      )

#      if scope.c
#        $(element).draggable("option", "helper", "clone")
])

.directive('droppable', [
  'EditorNode'

  (EditorNode) ->
    restrict: 'A'

    link: (scope, element, attrs) ->
#      insertZone = 8

      $('.dropzone').droppable(
        accept: '.node, .component'
        tolerance: 'pointer'

        drop: (event, ui) ->
          src = angular.element(ui.draggable).scope()
          dst = angular.element(this).scope()
          s = if src.n then src.n else src.c
          d = dst.n

          # Move node
          if s and s.$data.isNode and s.canMove(d, false)
            s.move(d, false, (result) ->
              EditorNode.setSelection(result)
            )

          # Insert component
          else if d.canAdd(s, false)
            d.add(s.name, s, false, (result) ->
              EditorNode.setSelection(result)
            )

          $(ui.helper).removeClass('drag-invalid')
          $(this).removeClass('dropzone-hover')
          $(".dropzone").removeClass('dropzone-active')

        over: (event, ui) ->
          src = angular.element(ui.draggable).scope()
          dst = angular.element(this).scope()
          s = if src.n then src.n else src.c
          d = dst.n

          $(this).addClass('dropzone-hover')
          $("#dropzone_" + d._id).addClass('dropzone-active')

          if (s and s.$data.isNode and !s.canMove(d, false)) or (!d.canAdd(s, false))
            $(ui.helper).addClass('drag-invalid')
          else
            $(ui.helper).removeClass('drag-invalid')

        out: (event, ui) ->
#          $(ui.helper).removeClass('drag-invalid')
          $(this).removeClass('dropzone-hover')
          $(".dropzone").removeClass('dropzone-active')
      )

      $('.node').droppable(
        accept: '.node, .component'
        tolerance: 'pointer'
        greedy: true

        drop: (event, ui) ->
          src = angular.element(ui.draggable).scope()
          dst = angular.element(this).scope()
          s = if src.n then src.n else src.c
          d = dst.n

          # Move node
          if s and s.$data.isNode and s.canMove(d)
            s.move(d, true, (result) ->
#                Node.setSelection(result)
            )

          # Insert component
          else if s and s.$data.isComponent and d.canAdd(s, true)
            d.add(s.name, s, true, (result) ->
#              Node.setSelection(result)
            )

          $(ui.helper).removeClass('drag-invalid')
          $(this).removeClass('drag-hover')

#          $(".node").each(() ->
#            $this = $(this)
#            $this.removeClass('drag-insert-top')
#            $this.removeClass('drag-insert-bottom')
#          )

        over: (event, ui) ->
          src = angular.element(ui.draggable).scope()
          dst = angular.element(this).scope()
          s = if src.n then src.n else src.c
          d = dst.n

#          $(".node").each(() ->
#            $this = $(this)
#            $this.removeClass('drag-insert-top')
#            $this.removeClass('drag-insert-bottom')
#          )

          $(this).addClass('drag-hover')

          if (s and s.$data.isNode and !s.canMove(d, true)) or !d.canAdd(s, true)
            $(ui.helper).addClass('drag-invalid')
          else
            $(ui.helper).removeClass('drag-invalid')
#            $this = $(this)
#            cOffset = $this.offset()
#            if event.pageX >= cOffset.left and event.pageX <= cOffset.left + $this.width()
#              bottomPos = cOffset.top + $this.height()
#              if event.pageY >= cOffset.top and event.pageY <= cOffset.top + insertZone
#                $this.addClass('drag-insert-top')
#              if event.pageY >= bottomPos - insertZone and event.pageY <= bottomPos
#                $this.addClass('drag-insert-bottom')

        out: (event, ui) ->
#          $(ui.helper).removeClass('drag-invalid')
          $(this).removeClass('drag-hover')
      )

      $('.node-property-value-col').droppable(
        accept: '.node, .component'
        tolerance: 'pointer'
        greedy: true

        drop: (event, ui) ->
          src = angular.element(ui.draggable).scope()
          dst = angular.element(this).scope()
          s = if src.n then src.n else src.c
          d = dst.np

          if d and s and d.canAdd(s) and (s.$data.isNode or s.$data.isComponent)
            d.add(s.name, s)

          $(ui.helper).removeClass('drag-invalid')
          $(this).removeClass('drag-hover')

#          $(".node").each(() ->
#            $this = $(this)
#            $this.removeClass('drag-insert-top')
#            $this.removeClass('drag-insert-bottom')
#          )

          event.stopPropagation()

        over: (event, ui) ->
          src = angular.element(ui.draggable).scope()
          dst = angular.element(this).scope()
          s = if src.n then src.n else src.c
          d = dst.np

#          $(".node").each(() ->
#            $this = $(this)
#            $this.removeClass('drag-insert-top')
#            $this.removeClass('drag-insert-bottom')
#          )

          $(this).addClass('drag-hover')

          if d and s and !d.canAdd(s) and (s.$data.isNode or s.$data.isComponent)
              $(ui.helper).addClass('drag-invalid')
            else
              $(ui.helper).removeClass('drag-invalid')
  #            $this = $(this)
  #            cOffset = $this.offset()
  #            if event.pageX >= cOffset.left and event.pageX <= cOffset.left + $this.width()
  #              bottomPos = cOffset.top + $this.height()
  #              if event.pageY >= cOffset.top and event.pageY <= cOffset.top + insertZone
  #                $this.addClass('drag-insert-top')
  #              if event.pageY >= bottomPos - insertZone and event.pageY <= bottomPos
  #                $this.addClass('drag-insert-bottom')

          event.stopPropagation()

        out: (event, ui) ->
#          $(ui.helper).removeClass('drag-invalid')
          $(this).removeClass('drag-hover')
      )

])
