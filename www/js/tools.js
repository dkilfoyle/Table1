<script src="js/jquery-ui-1.10.3.custom.min.js"></script>

<link href="js/select2/select2.css" rel="stylesheet"/>
<script src="js/select2/select2.js"></script>
<script src="js/select2.sortable.js"></script>

<script>
/* implement select2 support for the field selects */
$(document).ready(function() {
  $("#numerics").select2({ width: 'resolve', placeholder: 'Select numeric(s)' }); $("#numerics").select2Sortable()
  $("#factors").select2({ width: 'resolve', placeholder: 'Select factor(s)' }); $("#factors").select2Sortable()
  $("#colFactor").select2({ width: 'resolve', placeholder: 'Select factor' }); $("#colFactor").select2Sortable()
  $("#dataset").select2({ width: 'resolve', placeholder: 'Select dataframe' }); $("#dataset").select2Sortable()
});

</script>
