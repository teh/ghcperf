{ stdenv, fetchFromGitHub, pythonPackages }:

pythonPackages.buildPythonApplication rec {
  name = "s3cmd-1.6.1";

  src = fetchFromGitHub {
    rev = "4c2489361d353db1a1815172a6143c8f5a2d1c40";
    sha256 = "0aan6v1qj0pdkddhhkbaky44d54irm1pa8mkn52i2j86nb2rkcf9";
    repo = "s3cmd";
    owner = "s3tools";
  };

  propagatedBuildInputs = with pythonPackages; [ python_magic dateutil ];

  meta = with stdenv.lib; {
    homepage = http://s3tools.org/;
    description = "A command-line tool to manipulate Amazon S3 buckets";
    license = licenses.gpl2;
    maintainers = [ maintainers.spwhitt ];
    platforms = platforms.all;
  };
}
