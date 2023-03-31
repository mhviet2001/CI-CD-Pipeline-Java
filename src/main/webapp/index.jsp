<!DOCTYPE html>
<html>

<head>
    <title>My Portfolio</title>
    <link rel="stylesheet" type="text/css" href="style.css">
</head>

<body>
    <header>
        <h1>My Portfolio</h1>
    </header>
    <main>
        <section>
            <h2>About Me</h2>
            <p>Hello, my name is [your name]. I am a [your profession] based in [your location].</p>
        </section>
        <section>
            <h2>My Work</h2>
            <div class="gallery">
                <img src="img/project1.jpg">
                <img src="img/project2.jpg">
                <img src="img/project3.jpg">
            </div>
        </section>
        <section>
            <h2>Contact Me</h2>
            <form>
                <label for="name">Name:</label>
                <input type="text" id="name" name="name">
                <label for="email">Email:</label>
                <input type="email" id="email" name="email">
                <label for="message">Message:</label>
                <textarea id="message" name="message"></textarea>
                <input type="submit" value="Send">
            </form>
        </section>
    </main>
    <footer>
        <p>Copyright © [year] [your name].
            All rights reserved.</p>
    </footer>
</body>

</html> 