<script>
/* 1. define variables */
var me = "max-n";
var place = "posteo.de";

/* 2. find email link to replace */
var elink = document.getElementById("mlink");

/* 3. replace link href with variables  */
elink.href = `mailto:${me}@${place}`;
</script>

<a id="mlink" href="#">email me</a>