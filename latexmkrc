sub generate_resume_data {
  my ($source, $target) = @_;
  my $generator = 'scripts/generate_resume.rb';
  my $target_time = -e $target ? (stat($target))[9] : 0;
  my $source_time = (stat($source))[9];
  my $generator_time = (stat($generator))[9];

  if ($source_time > $target_time || $generator_time > $target_time) {
    my $status = system('ruby', $generator, $source, $target);
    die "Failed to generate $target from $source\n" if $status != 0;
  }
}

generate_resume_data('curriculos/curriculo.yaml', 'curriculo.tex');
generate_resume_data('curriculos/curriculo-geral.yaml', 'curriculo-geral.tex');
